table 50100 "LVN Requisition Header"
{
    Caption = 'Purchase Requisition Header';
    DataClassification = ToBeClassified;
    LookupPageId = "Purchase Requisition List";
    DrillDownPageId = "Purchase Requisition List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = ToBeClassified;
        }
        field(3; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(4; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(5; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            DataClassification = ToBeClassified;
            ToolTip = 'Person who will source the item/service';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Purchaser Code");
            end;
        }
        field(6; "Status"; Enum "Requisition Status")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code".Code;
        }
        field(8; "Justification"; Text[250])
        {
            Caption = 'Justification';
            DataClassification = ToBeClassified;
        }
        field(9; "Requested By"; Code[20])
        {
            Caption = 'Requested By';
            DataClassification = ToBeClassified;
            ToolTip = 'Person who requested the item/service';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(10; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                Rec.ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(11; "Completely Converted to PO"; Boolean)
        {
            Caption = 'Completely Converted to PO';
            DataClassification = ToBeClassified;
        }
        field(12; "Total Estimated Amount"; Decimal)
        {
            Caption = 'Total Estimated Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("LVN Requisition Line"."Estimated Amount (LCY)" WHERE("Document No." = FIELD("No.")));
        }
        field(13; "Remark"; Text[250])
        {
            Caption = 'Remark';
            DataClassification = ToBeClassified;
        }
        field(14; "Purchase Type"; Enum "Purchase Type")
        {
            Caption = 'Purchase Type';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PurchaseLine: Record "Purchase Line";
            begin
                // Check if switching to Trade when Purchase Quotes exist
                if "Purchase Type" = "Purchase Type"::Trade then begin
                    PurchaseLine.Reset();
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Quote);
                    PurchaseLine.SetRange("PR No.", "No.");
                    if not PurchaseLine.IsEmpty then
                        Error('You must delete quote before selecting "Trade" type.');
                end;

                // Reset Vendor No. for Non-Trade
                if "Purchase Type" = "Purchase Type"::"Non-Trade" then begin
                    "Vendor No." := '';
                    "Truck No." := '';
                    "Driver Name" := '';
                    "Truck Weight" := 0;
                    "Arrived Date" := 0D;
                end;
            end;
        }
        field(15; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Vendor No." <> '' then begin
                    if Vendor.Get("Vendor No.") then begin
                        "Truck No." := Vendor."Truck No.";
                        "Driver Name" := Vendor."Driver Name";
                    end;
                end else begin
                    "Truck No." := '';
                    "Driver Name" := '';
                end;
            end;
        }
        field(16; "Truck No."; Code[20])
        {
            Caption = 'Truck No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; "Driver Name"; Text[100])
        {
            Caption = 'Driver Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; "Truck Weight"; Decimal)
        {
            Caption = 'Truck Weight';
            DataClassification = ToBeClassified;
        }
        field(19; "Arrived Date"; Date)
        {
            Caption = 'Arrived Date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Arrived Date" = 0D then
                    "Arrived Date" := Today;
            end;
        }

    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        lcuPRSetup: Record "PR Setup";
        lcuNoSeries: Codeunit "No. Series";
    begin
        "Document Date" := Today;
        "Status" := "Requisition Status"::Draft;
        lcuPRSetup.Get();
        if "No." = '' then
            "No." := lcuNoSeries.GetNextNo(lcuPRSetup."PR No. Series");
    end;

    //Restrict deletion if approval entries exist for current requisition header
    trigger OnDelete()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if ApprovalsMgmt.HasApprovalEntries(Rec.RecordId) then
            Error('Cannot delete the purchase requisition header %1 because related approval entries exist', Rec."No.");
    end;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1', "No."));
    end;

    //check if there are lines exist for this Requisition Header
    procedure RequisitionLinesExist(): Boolean
    var
        PRLine: Record "LVN Requisition Line";
    begin
        PRLine.Reset();
        PRLine.ReadIsolation := IsolationLevel::ReadUncommitted;
        PRLine.SetRange("Document No.", "No.");
        exit(not PRLine.IsEmpty);
    end;

    /// <summary>
    /// Filters the PR header for responsibility center set in the PR setup.
    /// The filter is set in filter group 2 and is hidden from the user.
    /// </summary>
    /// <remarks>
    /// Responsibility filter is set from PR setup if user has PR admin role, then he can see all PR.
    /// Otherwise filter by current user's responsibility center.
    /// </remarks>
    procedure SetSecurityFilterOnPR()
    var
        AccessControl: Record "Access Control";
        PRSetup: Record "PR Setup";
        HasProcurementAdminRole: Boolean;
    begin
        // If no PR Setup or no admin role configured, show all PR
        if not PRSetup.Get() or (PRSetup."PR Admin Role" = '') then
            exit;

        // Check if user has the configured admin role
        AccessControl.Reset();
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", PRSetup."PR Admin Role");
        HasProcurementAdminRole := not AccessControl.IsEmpty;

        // If user doesn't have Procurement Admin Role, filter to show only their created PR
        if not HasProcurementAdminRole then begin
            FilterGroup(2);
            SetRange("Requested By", UserId());
            FilterGroup(0);
        end;
        // If user has Procurement Admin Role, no filter applied - can see all PR
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify();
        if OldDimSetID <> "Dimension Set ID" then begin
            if not IsNullGuid(Rec.SystemId) then
                Modify();
        end;
    end;

    procedure UpdateCompletelyConvertedToPO()
    var
        lrPRLine: Record "LVN Requisition Line";
        AllCompleted: Boolean;
    begin
        AllCompleted := false;
        lrPRLine.Reset();
        lrPRLine.SetRange("Document No.", "No.");
        if lrPRLine.FindFirst() then begin
            AllCompleted := true;
            repeat
                if not lrPRLine.Completed then begin
                    AllCompleted := false;
                    break;
                end;
            until lrPRLine.Next() = 0;
        end;

        if Rec."Completely Converted to PO" <> AllCompleted then begin
            Rec."Completely Converted to PO" := AllCompleted;
            Modify();
        end;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
}