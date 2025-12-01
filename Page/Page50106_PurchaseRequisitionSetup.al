page 50106 "Purchase Requisition Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PR Setup";
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("PR No. Series"; Rec."PR No. Series")
                {
                    ToolTip = 'Specifies the number series used to number new Purchase Requisitions.';
                    ApplicationArea = All;
                }
                field("PR Admin Role"; Rec."PR Admin Role")
                {
                    ToolTip = 'Specifies the role that has permissions to approve Purchase Requisitions.';
                    ApplicationArea = All;
                }
                field("Auto Create PO"; Rec."Auto Create PO")
                {
                    ToolTip = 'Specifies whether a Purchase Order is automatically created when a Sourcing line is approved.';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if rec.IsEmpty then rec.Insert();
    end;
}