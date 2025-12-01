permissionset 50111 "PR ADMIN"
{
    Assignable = true;
    Caption = 'Purchase Requisition Admin';

    Permissions =
        table "LVN Requisition Header" = X,
        table "LVN Requisition Line" = X,
        table "PR Setup" = X,
        tabledata "LVN Requisition Header" = RMID,
        tabledata "LVN Requisition Line" = RMID,
        tabledata "PR Setup" = RMID,
        page "Purchase Requisition List" = X,
        page "Purchase Requisition Card" = X,
        page "PR Subform" = X,
        page "PR Sourcing Line" = X,
        page "Purchase Requisition Setup" = X,
        page "PR Purchase Orders" = X,
        report "Create Purchase Quote" = X,
        report "Status Report" = X,
        codeunit "PR Workflow Management" = X;
}