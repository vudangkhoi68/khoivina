table 50101 "LVN Requisition Line"
{
    Caption = 'Purchase Requisition Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            TableRelation = "LVN Requisition Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Type"; Enum "LVN Requisition Line Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                "No." := '';
                "Variant Code" := ''
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
            TableRelation = if (Type = const(" ")) "Standard Text"
            else
            if (Type = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false))
            else
            if (Type = const(Item)) Item where(Blocked = const(false));
            trigger OnValidate()
            var
                StandardText: Record "Standard Text";
                GLAcc: Record "G/L Account";
                Item: Record Item;
            begin
                case Type of
                    Type::" ":
                        begin
                            Description := StandardText.Description;
                        end;
                    Type::"G/L Account":
                        begin
                            TestField("No.");
                            GLAcc.Get("No.");
                            Description := GLAcc.Name;
                        end;
                    Type::Item:
                        begin
                            TestField("No.");
                            Item.Get("No.");
                            Description := Item.Description;
                        end;
                end;
            end;
        }
        field(5; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = ToBeClassified;
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."), Blocked = const(false));
        }
        field(6; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
            ValidateTableRelation = false;
            TableRelation = if (Type = const("G/L Account")) "G/L Account".Name where("Direct Posting" = const(true),
                                "Account Type" = const(Posting),
                                Blocked = const(false))
            else
            if (Type = const(Item)) Item.Description where(Blocked = const(false));
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(8; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
            TableRelation = if (Type = const(Item),
                                "No." = filter(<> '')) "Item Unit of Measure".Code where("Item No." = field("No."))
            else if (Type = filter("G/L Account")) "Unit of Measure";
        }
        field(9; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //check if Quantity is less than 0, prompt error
                if ("Quantity" <= 0) then
                    Error('Quantity cannot be less than zero.');
                "Estimated Amount (LCY)" := "Estimated Unit Cost (LCY)" * "Quantity"
            end;
        }
        field(10; "Estimated Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Estimated Unit Cost (LCY)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                //check if Estimated Unit Cost (LCY) is less than 0, prompt error
                if ("Estimated Unit Cost (LCY)" < 0) then
                    Error('Estimated Unit Cost (LCY) cannot be less than zero.');
                "Estimated Amount (LCY)" := "Estimated Unit Cost (LCY)" * "Quantity"
            end;
        }
        field(11; "Estimated Amount (LCY)"; Decimal)
        {
            Caption = 'Estimated Amount (LCY)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Completed"; Boolean)
        {
            Caption = 'Completed';
            DataClassification = ToBeClassified;
            ToolTip = 'Indiciates if the PR line has been completely received';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Line No." := GetNextLineNo("Document No.");
    end;

    procedure GetNextLineNo(DocumentNo: Code[20]): Integer
    var
        lrReqLine: Record "LVN Requisition Line";
    begin
        lrReqLine.Reset();
        lrReqLine.SetRange("Document No.", DocumentNo);
        if lrReqLine.FindLast() then
            exit(lrReqLine."Line No." + 10000)
        else
            exit(10000);
    end;

    //Restrict deletion if approval entries exist for related requisition header
    trigger OnDelete()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        lrPRHeader: Record "LVN Requisition Header";
        PurchaseLine: Record "Purchase Line";
    begin
        lrPRHeader.Reset();
        lrPRHeader.SetRange("No.", Rec."Document No.");
        if ApprovalsMgmt.HasApprovalEntries(lrPRHeader.RecordId) then
            Error('Cannot delete the purchase requisition line because approval entries exist for the related requisition header.');

        // Delete related Purchase Line quotes
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Quote);
        PurchaseLine.SetRange("PR No.", Rec."Document No.");
        PurchaseLine.SetRange("PR Line No.", Rec."Line No.");
        PurchaseLine.DeleteAll(true);
    end;

    procedure SetCompleted()
    var
        lrPRHeader: Record "LVN Requisition Header";
    begin
        if not Completed then begin
            Completed := true;
            Modify();
            // Update PR Header Completely Converted to PO flag
            if lrPRHeader.Get("Document No.") then
                lrPRHeader.UpdateCompletelyConvertedToPO();
        end;
    end;
}