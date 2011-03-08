/*  This file is part of NCDSS Daysheets.

    NCDSS Daysheets is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NCDSS Daysheets is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with NCDSS Daysheets.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;

public partial class MasterPage : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        CheckLogin();
    }

    public void CheckLogin()
    {
        if (GetCurrentPageName() != "invalidUser.aspx")
        {
            GetUser();
            if (Session["UserType"] == null)
                GetUser();

            if (Session["UserType"].Equals(""))
                Response.Redirect("invalidUser.aspx", true);
        }
    }

    protected string GetCurrentPageName()
    {
        string sPath = System.Web.HttpContext.Current.Request.Url.AbsolutePath;
        System.IO.FileInfo oInfo = new System.IO.FileInfo(sPath);
        string sRet = oInfo.Name;
        return sRet;
    }

    protected void GetUser()
    {
        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_get_UserType_ForUser", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@UserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@UserID"].Value = HttpContext.Current.User.Identity.Name.ToString();

        objCmd.Parameters.Add(new SqlParameter("@UserType", SqlDbType.NVarChar, 20));
        objCmd.Parameters["@UserType"].Direction = ParameterDirection.Output;

        objCmd.Parameters.Add(new SqlParameter("@IsSupervisor", SqlDbType.Bit));
        objCmd.Parameters["@IsSupervisor"].Direction = ParameterDirection.Output;

        objCmd.UpdatedRowSource = UpdateRowSource.OutputParameters;
        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        Session["UserType"] = objCmd.Parameters["@UserType"].Value.ToString();
        Session["IsSupervisor"] = objCmd.Parameters["@IsSupervisor"].Value.ToString();
    }

    protected string BuildMenu()
    {
        string strMenu = "";
        strMenu = "<a href='default.aspx'>Home</a><br />";
        if ((Session["UserType"].ToString() == "Admin") ||
             (Session["UserType"].ToString() == "Case+Social Worker") ||
             (Session["UserType"].ToString() == "Caseworker") ||
             (Session["UserType"].ToString() == "Social Worker"))
        {
            strMenu = strMenu + "<a href='daysheet.aspx'>Today's Daysheet</a><br />";
            strMenu = strMenu + "<a href='month.aspx'>Current Month</a><br />";
            strMenu = strMenu + "<a href='month.aspx?m=-1'>Last Month</a><br />";
        }
        if ((Session["IsSupervisor"].ToString() == "True") || (Session["UserType"].ToString() == "Admin"))
        {
            strMenu = strMenu + "<a href='review.aspx'>Review & Approve</a><br />";
        }
        strMenu = strMenu + "<a href='preferences.aspx'>Preferences</a><br />";
        if ((Session["UserType"].ToString() == "Admin") || (Session["UserType"].ToString() == "Finance"))
        {
            strMenu = strMenu + "<a href='admin.aspx'>Admin Menu</a><br />";
        }
        strMenu = strMenu + "<a href='" + System.Configuration.ConfigurationManager.AppSettings["ReportListView"] + "'>Reports</a><br />";
        return strMenu;
    }
}
