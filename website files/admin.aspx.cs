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

public partial class _default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected string BuildAdminMenu()
    {
        string strMenu = "";
        strMenu = "<ul>";
        if ((Session["UserType"].ToString() == "Admin"))
        {
            strMenu = strMenu + "<li><a href='sisUpload.aspx'>Add Clients (SIS # Upload)</a></li>";
            strMenu = strMenu + "<li><a href='clients.aspx'>Edit Clients</a></li>";
        }
        if ((Session["UserType"].ToString() == "Admin") || (Session["UserType"].ToString() == "Finance"))
        {
            strMenu = strMenu + "<li><a href='announcements.aspx'>Add/Edit Announcements</a></li>";
            strMenu = strMenu + "<li><a href='" + System.Configuration.ConfigurationManager.AppSettings["ReportListView"] + "'>Reports</a></li>";   
        }
        if ((Session["UserType"].ToString() == "Finance"))
        {
            strMenu = strMenu + "<li><a href='upload.aspx'>Upload Data to State</a></li>";
        }
        strMenu = strMenu + "</ul>";
        return strMenu;
    }
}
