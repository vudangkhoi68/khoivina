tableextension 50104 PR_DocumentAttachmentExt extends "Document Attachment"
{
    fields
    {
        field(50104; "Mark for Approval"; Boolean)
        {
            Caption = 'Mark for Approval';
            DataClassification = ToBeClassified;
        }
    }
    trigger OnInsert()
    var
        lrPRHeader: Record "LVN Requisition Header";
    begin
        if "Table ID" = Database::"LVN Requisition Header" then
            if lrPRHeader.Get("No.") then begin
                Message('Document uploaded for %1', lrPRHeader."No.");
            end;
    end;
}