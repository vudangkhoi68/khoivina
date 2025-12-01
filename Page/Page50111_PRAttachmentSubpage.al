page 50111 "PR Attachment"
{
    PageType = ListPart;
    SourceTable = "Document Attachment";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Mark for Approval"; Rec."Mark for Approval")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the filename of the attachment.';
                    trigger OnDrillDown()
                    var
                        Selection: Integer;
                    begin
                        if Rec.HasContent() then
                            if Rec.SupportedByFileViewer() then
                                Rec.ViewFile()
                            else
                                Rec.Export(true)
                    end;
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Attached Date"; Rec."Attached Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }
        }
    }

}