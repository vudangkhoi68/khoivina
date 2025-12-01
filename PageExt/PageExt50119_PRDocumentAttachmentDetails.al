pageextension 50119 PRDocumentAttachmentDetails extends "Document Attachment Details"
{
    layout
    {

        addfirst(Group)
        {
            field("Mark for Approval"; Rec."Mark for Approval")
            {
                ApplicationArea = All;
                Width = 15;
                Visible = isPRModule;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateVisibility();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateVisibility();
    end;

    local procedure UpdateVisibility()
    begin
        isPRModule := Rec."Table ID" = Database::"LVN Requisition Header";
        CurrPage.Update(false);
    end;

    var
        isPRModule: Boolean;
}