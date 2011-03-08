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

public partial class _default : System.Web.UI.Page
{
    DateTime ShowDate = System.DateTime.Now.Date;
    int intTotal = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.QueryString["m"] != null)
            {
                try
                {
                    ShowDate = ShowDate.AddMonths(Int32.Parse(Request.QueryString["m"]));
                }
                catch
                {
                    // ignore invalid 'm' parameter -- show current month
                }
            }
            ddMonth.Items.Add(new ListItem(System.DateTime.Now.ToString("MMMM yyyy"), "0"));
            ddMonth.Items.Add(new ListItem(System.DateTime.Now.AddMonths(-1).ToString("MMMM yyyy"), "-1"));
            if (Request.QueryString["m"] != null)
                ddMonth.SelectedValue = Request.QueryString["m"];
        }
        else
        {
            ErrorMessageLabel.Visible = false;
            GridView1.Visible = true;
        }
    }

    protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        e.Command.Parameters["@SupervisorID"].Value = HttpContext.Current.User.Identity.Name.ToString();
    }

    protected string GetDateHeader()
    {
        return ShowDate.ToString("MMMM yyyy");
    }

    protected void ddMonth_SelectedIndexChanged(object sender, EventArgs e)
    {
        Response.Redirect(Page.Request.Url.LocalPath + "?m=" + ddMonth.SelectedValue.ToString(), true);
    }
    protected void GridView1_DataBound(object sender, EventArgs e)
    {

    }
    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            try
            {
                intTotal = intTotal + Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "MinutesForMonth"));
            }
            catch
            {
            }
        }
        else if (e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Text = "Total:";
            e.Row.Cells[1].HorizontalAlign = HorizontalAlign.Right;
            e.Row.Cells[2].Text = intTotal.ToString("N0");
        }
    }
}
