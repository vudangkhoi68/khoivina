table 50102 "PR Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
        }
        field(2; "PR No. Series"; Code[20])
        {
            Caption = 'Procurement No. Series';
            TableRelation = "No. Series".Code;
            DataClassification = ToBeClassified;
        }
        field(3; "PR Admin Role"; Code[20])
        {
            Caption = 'Procurement Admin Role';
            TableRelation = "Tenant Permission Set"."Role ID";
            DataClassification = ToBeClassified;
        }
        field(4; "Auto Create PO"; Boolean)
        {
            Caption = 'Auto Create Purchase Order';
            ToolTip = 'Auto create PO upon PQ approved.';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

}