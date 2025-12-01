permissionset 50110 "PR USER"
{
    Assignable = true;
    Caption = 'Purchase Requisition User';

    Permissions = 
        table "LVN Requisition Header" = X,
        table "LVN Requisition Line" = X,
        tabledata "LVN Requisition Header" = RMID,
        tabledata "LVN Requisition Line" = RMID,
        page "Purchase Requisition List" = X,
        page "Purchase Requisition Card" = X,
        page "PR Subform" = X,
        page "PR Sourcing Line" = X,
        page "PR Purchase Orders" = X,
        report "Create Purchase Quote" = X,
        report "Status Report" = X,
        codeunit "PR Workflow Management" = X;
}