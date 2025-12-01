page 50100 "Purchase Requisition List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "LVN Requisition Header";
    DeleteAllowed = false;
    ModifyAllowed = false;
    CardPageId = "Purchase Requisition Card";
    Editable = false;
    RefreshOnActivate = true;
    SourceTableView = where(Status = FILTER(Draft | PendingApproval | Released));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Justification"; Rec."Justification")
                {
                    ApplicationArea = All;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("Completely Converted to PO"; Rec."Completely Converted to PO")
                {
                    ApplicationArea = All;
                }
                field("Total Estimated Amount"; Rec."Total Estimated Amount")
                {
                    ApplicationArea = All;
                }
                field("Remark"; Rec."Remark")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PrintStatusReport)
            {
                Caption = 'Print Status Report';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Print the status report for the selected PR records. If no PR is selected, the system will show an error message.';

                trigger OnAction()
                var
                    StatusReport: Report "Status Report";
                    PRList: Record "LVN Requisition Header";
                begin
                    //CurrPage.SetSelectionFilter(Rec);
                    Clear(StatusReport);
                    StatusReport.SetTableView(PRList);
                    StatusReport.GerDepartmentCode(PRList);
                    StatusReport.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        rec.SetSecurityFilterOnPR();
    end;
}