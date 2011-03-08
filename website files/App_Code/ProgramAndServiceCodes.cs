using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections.Generic;
using AjaxControlToolkit;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Summary description for ProgramAndServiceCodes
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class ProgramAndServiceCodes : System.Web.Services.WebService {

    public ProgramAndServiceCodes () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    // Web method to get all the service codes for a given programCodeID
    // In params: knownCategoryValues from the cascading dropdown
    // Out params: CascadingDropDownNameValue array
    [WebMethod]
    public CascadingDropDownNameValue[] GetServiceCodesByProgramCode(string knownCategoryValues, string category)
    {
        // Split the knownCategoryValues on ":" with ";" delimiter 
        // For the first dropdownlist, the values will be "undefined: id of the dropdownelement"
        // ex: "undefined: 13;"
        // The string at index 1 will be the CarId selected in the dropdownlist.
        string[] _categoryValues = knownCategoryValues.Split(':', ';');

        // Convert the element at index 1 in the string[] to get the ProgramCode
        string _programCodeID = _categoryValues[1];

        // Create a List<T> of CascadingDropDownNameValue to hold the ServiceCode data
        List<CascadingDropDownNameValue> _serviceCodes = new List<CascadingDropDownNameValue>();

        // Create an instance of ServiceCodes TableAdapter
        dsServiceCodeTableAdapters.ServiceCodesTableAdapter _serviceCodeAdapter =
            new dsServiceCodeTableAdapters.ServiceCodesTableAdapter();
        
        // For each datarow in the DataTable returned by the GetServiceCodesByProgramCode method, add 
        // the ServiceCodeDescription and ServiceCodeID to the List<T>
        foreach (DataRow _row in _serviceCodeAdapter.get_ServiceCodes_forProgramCode(_programCodeID))
        {
            _serviceCodes.Add(new CascadingDropDownNameValue(_row["ServiceCodeDescription"].ToString(),
             _row["ServiceCodeWithClientIDFlag"].ToString()));
        }

        // convert to array and return the values
        return _serviceCodes.ToArray();
    }

    [WebMethod]
    public CascadingDropDownNameValue[] GetProgramCodesByServiceCode(string knownCategoryValues, string category)
    {
        // Split the knownCategoryValues on ":" with ";" delimiter 
        // For the first dropdownlist, the values will be "undefined: id of the dropdownelement"
        // ex: "undefined: 13;"
        // The string at index 1 will be the CarId selected in the dropdownlist.
        string[] _categoryValues = knownCategoryValues.Split(':', ';');

        // Convert the element at index 1 in the string[] to get the Service Code
        string _serviceCodeID = _categoryValues[1];

        // Create a List<T> of CascadingDropDownNameValue to hold the Program Code data
        List<CascadingDropDownNameValue> _programCodes = new List<CascadingDropDownNameValue>();

        // Create an instance of ProgramCodes TableAdapter
        dsProgramCodeTableAdapters.ProgramCodesTableAdapter _programCodeAdapter =
            new dsProgramCodeTableAdapters.ProgramCodesTableAdapter();

        // NOTE -- modified to accept ServiceCodeWithClientID values
        if ( _serviceCodeID.Length > 3 )
            _serviceCodeID = _serviceCodeID.Substring(_serviceCodeID.Length-3);

        foreach (DataRow _row in _programCodeAdapter.get_ProgramCodes_ForServiceCode(_serviceCodeID))
        {
            _programCodes.Add(new CascadingDropDownNameValue(_row["ProgramCodeDescription"].ToString(),
             _row["ProgramCodeID"].ToString()));
        }

        // convert to array and return the values
        return _programCodes.ToArray();
    }    
}

