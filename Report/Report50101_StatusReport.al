report 50101 "Status Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    RDLCLayout = 'Layout/Report50101_PR Status.rdlc';
    Caption = 'PR Status Report';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(DataItemName; "LVN Requisition Header")
        {
            //RequestFilterFields = "Document Date", "Status";

            column(PR_No; "No.")
            {
            }
            column(Department; "Shortcut Dimension 1 Code")
            {
            }
            dataitem(ReasonDesciption; "Reason Code")
            {
                DataItemLink = "Code" = field("Reason Code");

                column(Reason_Code; Reason)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Reason := ReasonDesciption.Description;
                end;

            }
            column(Purchase_Type; "Purchase Type")
            {
            }
            column(Requested_By; "Requested By")
            {
            }
            column(PR_Date; FormatDate("Document Date"))
            {
            }
            column(Fromdate; FormatDate(Fromdate))
            {
            }
            column(Todate; FormatDate(Todate))
            {
            }
            column(Date; FormatDate(Today))
            {
            }
            column(Status; "Status")
            {
            }
            column(Remark; "Remark")
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            column(CompanyPic; CompanyInfo.Picture)
            {
            }
            column(DraftLbl; DraftLbl)
            {
            }
            column(PendingApprovalLbl; PendingApprovalLbl)
            {
            }
            column(ReleasedLbl; ReleasedLbl)
            {
            }
            column(CancelledLbl; CancelledLbl)
            {
            }
            column(CompletedLbl; CompletedLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(PrNoLbl; PRNoLbl)
            {
            }
            column(DepartmentLbl; DepartmentLbl)
            {
            }
            column(ReasonCodeLbl; ReasonCodeLbl)
            {
            }
            column(PurchaseTypeLbl; PurchaseTypeLbl)
            {
            }
            column(RequestedByLbl; RequestedByLbl)
            {
            }
            column(PRDateLbl; PRDateLbl)
            {
            }
            column(TotalAmountLbl; TotalAmountLbl)
            {
            }
            column(StatusLbl; StatusLbl)
            {
            }
            column(RemarksLbl; RemarksLbl)
            {
            }
            column(TotalAmount; "Total Estimated Amount")
            {
            }
            column(CountRecordsColumn; CountRecords)
            {
            }
            column(CountRecordsDraftColumn; CountRecordsDraft)
            {
            }
            column(CountRecordsPendingApprovalColumn; CountRecordsPendingApproval)
            {
            }
            column(CountRecordsReleasedColumn; CountRecordsReleased)
            {
            }
            column(CountRecordsCancelledColumn; CountRecordsCancelled)
            {
            }
            column(CountRecordsCompletedColumn; CountRecordsCompleted)
            {
            }
            column(ShowDraftColumn; ShowDraft) { }
            column(ShowPendingApprovalColumn; ShowPendingApproval) { }
            column(ShowReleasedColumn; ShowReleased) { }
            column(ShowCancelledColumn; ShowCancelled) { }
            column(ShowCompletedColumn; ShowCompleted) { }
            column(Show; ShowCompleted) { }

            trigger OnAfterGetRecord()
            var
                Draft: Integer; // Draft
                PendingApproval: Integer; // Pending Approval
                Released: Integer; // Released
                Cancelled: Integer; // Cancelled
                Completed: Integer; // Completed
                All: Integer; // All
            begin
                CountPRByStatus(Draft, PendingApproval, Released, Cancelled, Completed, All);
                CountRecordsDraft := Draft;
                CountRecordsPendingApproval := PendingApproval;
                CountRecordsReleased := Released;
                CountRecordsCancelled := Cancelled;
                CountRecordsCompleted := Completed;
                CountRecords := All;
            end;

            trigger OnPostDataItem()
            var
            begin
            end;

            trigger OnPreDataItem()
            begin
                // Date filter
                if FromDate <> 0D then
                    SETRANGE("Document Date", FromDate, ToDate);

                // Department
                if DepartmentFilter <> '' then
                    SETFILTER("Shortcut Dimension 1 Code", DepartmentFilter);

                // Status
                if StatusFilterOptions <> StatusFilterOptions::All then begin
                    case StatusFilterOptions of
                        StatusFilterOptions::Draft:
                            SETRANGE(Status, Enum::"Requisition Status"::Draft);
                        StatusFilterOptions::"Pending Approval":
                            SETRANGE(Status, Enum::"Requisition Status"::PendingApproval);
                        StatusFilterOptions::Released:
                            SETRANGE(Status, Enum::"Requisition Status"::Released);
                        StatusFilterOptions::Cancelled:
                            SETRANGE(Status, Enum::"Requisition Status"::Cancelled);
                        StatusFilterOptions::Completed:
                            SETRANGE(Status, Enum::"Requisition Status"::Completed);
                    end;
                end;

                // Purchase Type
                if PurchaseTypeFilterOptions <> PurchaseTypeFilterOptions::All then begin
                    case PurchaseTypeFilterOptions of
                        PurchaseTypeFilterOptions::"Non-Trade":
                            SETRANGE("Purchase Type", Enum::"Purchase Type"::"Non-Trade");
                        PurchaseTypeFilterOptions::"Trade":
                            SETRANGE("Purchase Type", Enum::"Purchase Type"::"Trade");
                    end;
                end;

            end;

        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'Filters';
                    field(Fromdate; Fromdate)
                    {
                        Caption = 'From Date';
                    }
                    field(Todate; Todate)
                    {
                        Caption = 'To Date';
                    }
                    field(Department; DepartmentFilter)
                    {
                        Caption = 'Department Code';
                    }
                    field(StatusFilter; StatusFilterOptions)
                    {
                        Caption = 'Status';
                        ApplicationArea = All;
                        ToolTip = 'Select status filter';

                    }
                    field(PurchaseTypeFilter; PurchaseTypeFilterOptions)
                    {
                        Caption = 'Purchase Type';
                        ApplicationArea = All;
                        ToolTip = 'Select purchase type filter';
                    }
                }
            }
        }
        trigger OnOpenPage()
        var
            LVNRequisitionHeader: Record "LVN Requisition Header";
        begin
            Fromdate := Today - 30;
            Todate := Today;
            if LVNRequisitionHeader."Shortcut Dimension 1 Code" <> '' then
                DepartmentFilter := LVNRequisitionHeader."Shortcut Dimension 1 Code";
        end;

        trigger OnInit()
        begin
            StatusFilterOptions := StatusFilterOptions::All;
            PurchaseTypeFilterOptions := PurchaseTypeFilterOptions::All;
        end;

    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        if StatusFilterOptions = StatusFilterOptions::All then
            ShowStatusAll := true
        else
            ShowStatusAll := false;

        ShowDraft := false;
        ShowPendingApproval := false;
        ShowReleased := false;
        ShowCancelled := false;
        ShowCompleted := false;

        if ShowStatusAll then begin
            ShowDraft := true;
            ShowPendingApproval := true;
            ShowReleased := true;
            ShowCancelled := true;
            ShowCompleted := true;
        end else begin
            case StatusFilterOptions of
                StatusFilterOptions::Draft:
                    ShowDraft := true;
                StatusFilterOptions::"Pending Approval":
                    ShowPendingApproval := true;
                StatusFilterOptions::Released:
                    ShowReleased := true;
                StatusFilterOptions::Cancelled:
                    ShowCancelled := true;
                StatusFilterOptions::Completed:
                    ShowCompleted := true;
            end;
        end;
    end;

    var
        CompanyInfo: Record "Company Information";
        Fromdate: Date;
        Todate: Date;
        PrNoLbl: Label 'PR No.';
        DepartmentLbl: Label 'Department';
        ReasonCodeLbl: Label 'Reason Code';
        PurchaseTypeLbl: Label 'Purchase Type';
        RequestedByLbl: Label 'Requested By';
        DraftLbl: Label 'Draft';
        PendingApprovalLbl: Label 'Pending Approval';
        ReleasedLbl: Label 'Released';
        CancelledLbl: Label 'Cancelled';
        CompletedLbl: Label 'Completed';
        TotalLbl: Label 'Total';
        PRDateLbl: Label 'PR Date';
        TotalAmountLbl: Label 'Total Amount';
        StatusLbl: Label 'Status';
        RemarksLbl: Label 'Remarks';
        gLVNRequisitionHeader: Record "LVN Requisition Header";
        DepartmentFilter: Code[20];
        CountRecords: Integer;
        CountRecordsDraft: Integer;
        CountRecordsPendingApproval: Integer;
        CountRecordsReleased: Integer;
        CountRecordsCancelled: Integer;
        CountRecordsCompleted: Integer;
        Reason: Text[100];
        ShowDraft: Boolean;
        ShowPendingApproval: Boolean;
        ShowReleased: Boolean;
        ShowCancelled: Boolean;
        ShowCompleted: Boolean;
        ShowStatusAll: Boolean;      // status ALL
        StatusFilterOptions: Option All,Draft,"Pending Approval",Released,Cancelled,Completed;
        PurchaseTypeFilterOptions: Option All,"Non-Trade","Trade";


    procedure GerDepartmentCode(pLVNRequisitionHeader: Record "LVN Requisition Header")

    begin
        gLVNRequisitionHeader := pLVNRequisitionHeader;
    end;

    procedure CountPRByStatus(var DraftCount: Integer;
                          var PendingApprovalCount: Integer;
                          var ReleasedCount: Integer;
                          var CancelledCount: Integer;
                          var CompletedCount: Integer;
                          var AllCount: Integer)
    var
        PR: Record "LVN Requisition Header";
    begin
        // Reset counters
        DraftCount := 0;
        PendingApprovalCount := 0;
        ReleasedCount := 0;
        CancelledCount := 0;
        CompletedCount := 0;
        AllCount := 0;

        PR.Reset();

        // Apply date filter
        if Fromdate <> 0D then
            PR.SetRange("Document Date", Fromdate, Todate);

        // Apply department filter
        if DepartmentFilter <> '' then
            PR.SetFilter("Shortcut Dimension 1 Code", DepartmentFilter);

        // Apply status filter
        if StatusFilterOptions <> StatusFilterOptions::All then begin
            case StatusFilterOptions of
                StatusFilterOptions::Draft:
                    PR.SetRange(Status, PR.Status::Draft);
                StatusFilterOptions::"Pending Approval":
                    PR.SetRange(Status, PR.Status::PendingApproval);
                StatusFilterOptions::Released:
                    PR.SetRange(Status, PR.Status::Released);
                StatusFilterOptions::Cancelled:
                    PR.SetRange(Status, PR.Status::Cancelled);
                StatusFilterOptions::Completed:
                    PR.SetRange(Status, PR.Status::Completed);
            end;
        end;

        // Apply purchase type filter
        if PurchaseTypeFilterOptions <> PurchaseTypeFilterOptions::All then begin
            case PurchaseTypeFilterOptions of
                PurchaseTypeFilterOptions::"Non-Trade":
                    PR.SetRange("Purchase Type", PR."Purchase Type"::"Non-Trade");
                PurchaseTypeFilterOptions::"Trade":
                    PR.SetRange("Purchase Type", PR."Purchase Type"::Trade);
            end;
        end;

        // Start counting after all filters applied
        if PR.FindSet() then begin
            repeat
                case PR.Status of
                    PR.Status::Draft:
                        DraftCount += 1;
                    PR.Status::PendingApproval:
                        PendingApprovalCount += 1;
                    PR.Status::Released:
                        ReleasedCount := ReleasedCount + 1;
                    PR.Status::Cancelled:
                        CancelledCount := CancelledCount + 1;
                    PR.Status::Completed:
                        CompletedCount := CompletedCount + 1;
                end;

                AllCount := AllCount + 1;

            until PR.Next() = 0;
        end;
    end;


    local procedure FormatDate(InputDate: Date): Text
    var
        FormattedDate: Text;
    begin
        if InputDate = 0D then
            exit('');

        // format date as DD/MM/YYYY
        FormattedDate := Format(InputDate, 0, '<Day,2>/<Month,2>/<Year4>');
        exit(FormattedDate);
    end;

}