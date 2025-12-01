enum 50102 "Requisition Status"
{
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; PendingApproval) { Caption = 'Pending Approval'; }
    value(2; Released) { Caption = 'Released'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
    value(4; Completed) { Caption = 'Completed'; }
}