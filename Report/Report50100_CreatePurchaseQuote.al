report 50100 "Create Purchase Quote"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Create Purchase Quote';

    dataset
    {
        dataitem(PRLine; "LVN Requisition Line")
        {
            trigger OnAfterGetRecord()
            var
                lrPRHeader: Record "LVN Requisition Header";
                lrPH: Record "Purchase Header";
                lrPL: Record "Purchase Line";
            begin
                // Validate Unit Price > 0
                if UnitPrice <= 0 then
                    Error('Unit Price must be greater than 0.');
                
                // Validate Vendor is not blank
                if VendorNo = '' then
                    Error('Vendor No. must be specified.');
                
                // Get PR Header
                if not lrPRHeader.Get("Document No.") then
                    Error('PR Header not found.');
                // Create PQ Header
                lrPH.Init();
                lrPH."Document Type" := lrPH."Document Type"::Quote;
                lrPH.Insert(true);
                lrPH.Validate("Buy-from Vendor No.", VendorNo);
                lrPH.Validate("Currency Code", CurrencyCode);
                lrPH.Validate("Document Date", PQDate);
                if lrPRHeader."Dimension Set ID" <> 0 then
                    lrPH."Dimension Set ID" := lrPRHeader."Dimension Set ID";
                lrPH.Modify(true);

                // Create PQ Line
                lrPL.Init();
                lrPL."Document Type" := lrPL."Document Type"::Quote;
                lrPL."Document No." := lrPH."No.";
                lrPL."Line No." := 10000;
                lrPL.Insert(true);
                lrPL.Validate(Type, "Type");
                lrPL.Validate("No.", "No.");
                lrPL.Validate("Variant Code", "Variant Code");
                lrPL.Validate("Location Code", "Location Code");
                lrPL.Validate("Unit of Measure Code", "Unit of Measure Code");
                lrPL.Validate(Quantity, Quantity);
                lrPL.Validate("PR No.", "Document No.");
                lrPL.Validate("PR Line No.", "Line No.");
                lrPL.Validate("Direct Unit Cost", UnitPrice);
                lrPL.Modify(true);

                // Open the PQ
                PAGE.Run(PAGE::"Purchase Quote", lrPH);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(VendorNo; VendorNo)
                    {
                        Caption = 'Vendor No.';
                        TableRelation = Vendor."No.";
                        ApplicationArea = All;
                    }
                    field(CurrencyCode; CurrencyCode)
                    {
                        Caption = 'Currency Code';
                        TableRelation = Currency;
                        ApplicationArea = All;
                    }
                    field(Date; PQDate)
                    {
                        Caption = 'Quote Date';
                        ApplicationArea = All;
                    }
                    field(UnitPrice; UnitPrice)
                    {
                        Caption = 'Unit Price';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if GLSetup.Get() then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := '';
        PQDate := Today();
    end;

    var
        VendorNo: Code[20];
        CurrencyCode: Code[10];
        PQDate: Date;
        UnitPrice: Decimal;
}