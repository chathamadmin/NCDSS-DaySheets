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
    DateTime datShowDate = System.DateTime.Now.Date;
    int intTotal = 0;

    protected void Page_PreInit(object sender, EventArgs e)
    {
        if ((Request.QueryString["m"] == null ? "0" : Request.QueryString["m"]) != "0")
        {
            Page.Theme = "AlternateTheme";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            MasterPage myMaster = (MasterPage)this.Master;
            myMaster.CheckLogin();
            CheckViewState();

            SetShowDate();
            SetMultiView();

            ddMonth.Items.Add(new ListItem(System.DateTime.Now.ToString("MMMM yyyy"), "0"));
            ddMonth.Items.Add(new ListItem(System.DateTime.Now.AddMonths(-1).ToString("MMMM yyyy"), "-1"));
            ddMonth.SelectedValue = (Request.QueryString["m"] == null ? "0" : Request.QueryString["m"]);
        }
        else
        {
            ErrorMessageLabel.Visible = false;
            GridView1.Visible = true;
            mvCertifyApprove.Visible = true;
        }
        hypPrintMonth.NavigateUrl = System.Configuration.ConfigurationManager.AppSettings["ReportServerURL"] + "Daysheet+Monthly+Report&Month=" + ViewState["UseMonth"] + "&Year=" + ViewState["UseYear"] + "&UserID=" + ViewState["DaysheetUserID"].ToString().ToLower() + "&rs:Command=Render&rs:Format=PDF";
    }

    protected void CheckViewState()
    {
        if (ViewState["DaysheetUserID"] == null)
        {
            if (Request.QueryString["u"] != null)
                ViewState["DaysheetUserID"] = Request.QueryString["u"];
            else
                ViewState["DaysheetUserID"] = HttpContext.Current.User.Identity.Name.ToString();
        }
    }

    protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void SetShowDate()
    {
        if (Request.QueryString["m"] != null)
        {
            try
            {
                datShowDate = datShowDate.AddMonths(Int32.Parse(Request.QueryString["m"]));
            }
            catch
            {
                // ignore invalid 'm' parameter -- show current month
            }
        }
        ViewState["UseMonth"] = datShowDate.Month;
        ViewState["UseYear"] = datShowDate.Year;
    }

    protected void SetMultiView()
    {
        bool HasPermission;
        bool IsCertified;
        bool IsApproved;

        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_get_DaysheetCertification_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@LoggedInUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@LoggedInUserID"].Value = HttpContext.Current.User.Identity.Name.ToString();

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@HasPermission", SqlDbType.Bit));
        objCmd.Parameters["@HasPermission"].Direction = ParameterDirection.Output;

        objCmd.Parameters.Add(new SqlParameter("@IsCertified", SqlDbType.Bit));
        objCmd.Parameters["@IsCertified"].Direction = ParameterDirection.Output;

        objCmd.Parameters.Add(new SqlParameter("@IsApproved", SqlDbType.Bit));
        objCmd.Parameters["@IsApproved"].Direction = ParameterDirection.Output;

        objCmd.UpdatedRowSource = UpdateRowSource.OutputParameters;
        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        HasPermission = (bool)objCmd.Parameters["@HasPermission"].Value;
        IsCertified = (bool)objCmd.Parameters["@IsCertified"].Value;
        IsApproved = (bool)objCmd.Parameters["@IsApproved"].Value;

        // if user does not have permission to view this record, show error
        if (!HasPermission)
        {
            ErrorMessageLabel.Text = "You are not listed as a supervisor for this user. Please contact the database administrator if this needs to be changed.";
            ErrorMessageLabel.Visible = true;
            GridView1.Visible = false;
            mvCertifyApprove.Visible = false;
            return;
        }

        if ((ViewState["DaysheetUserID"].ToString() != HttpContext.Current.User.Identity.Name.ToString())
                || (Session["UserType"].ToString() == "Admin"))
        {
            if (IsCertified)
            {
                if (IsApproved)
                    this.mvCertifyApprove.SetActiveView(vwSupervisorApproved);
                else
                    this.mvCertifyApprove.SetActiveView(vwSupervisorNotApproved);
            }
            else
                this.mvCertifyApprove.SetActiveView(vwSupervisorNotCertified);

        }
        else
        {
            if (IsCertified)
                this.mvCertifyApprove.SetActiveView(vwSelfCertified);
            else
                this.mvCertifyApprove.SetActiveView(vwSelfNotCertified);
        }
    }

    protected string GetDateHeader()
    {
        return datShowDate.ToString("MMMM yyyy");
    }

    protected void dsUserDetails_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void btnCertify_Click(object sender, EventArgs e)
    {
        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_update_DaysheetCertification_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Certified", SqlDbType.Int));
        objCmd.Parameters["@Certified"].Value = 1;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        if (Request.QueryString["u"] != null)
            Response.Redirect("review.aspx" + (Request.QueryString["m"] != null ? "?m=" + Request.QueryString["m"] : ""), true);
        else
            Response.Redirect(Page.Request.Url.ToString(), true);
    }

    protected void btnUncertify_Click(object sender, EventArgs e)
    {
        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_update_DaysheetCertification_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Certified", SqlDbType.Int));
        objCmd.Parameters["@Certified"].Value = 0;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        Response.Redirect(Page.Request.Url.ToString(), true);
    }

    protected void btnCertifyAndApprove_Click(object sender, EventArgs e)
    {
        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_update_DaysheetCertification_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Certified", SqlDbType.Int));
        objCmd.Parameters["@Certified"].Value = 1;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        objCmd = new SqlCommand("spc_update_DaysheetApproval_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Approved", SqlDbType.Int));
        objCmd.Parameters["@Approved"].Value = 1;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        Response.Redirect("review.aspx" + (Request.QueryString["m"] != null ? "?m=" + Request.QueryString["m"] : ""), true);
    }

    protected void btnApprove_Click(object sender, EventArgs e)
    {
        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_update_DaysheetApproval_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Approved", SqlDbType.Int));
        objCmd.Parameters["@Approved"].Value = 1;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        Response.Redirect("review.aspx" + (Request.QueryString["m"] != null ? "?m=" + Request.QueryString["m"] : ""), true);
    }

    protected void btnUndoCertifyAndApprove_Click(object sender, EventArgs e)
    {
        CheckViewState();

        SqlConnection objConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand objCmd = new SqlCommand("spc_update_DaysheetCertification_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Certified", SqlDbType.Int));
        objCmd.Parameters["@Certified"].Value = 0;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        objCmd = new SqlCommand("spc_update_DaysheetApproval_ForUserMonthYear", objConn);
        objCmd.CommandType = CommandType.StoredProcedure;

        objCmd.Parameters.Add(new SqlParameter("@DaysheetUserID", SqlDbType.NVarChar, 50));
        objCmd.Parameters["@DaysheetUserID"].Value = ViewState["DaysheetUserID"];

        objCmd.Parameters.Add(new SqlParameter("@DaysheetMonth", SqlDbType.Int));
        objCmd.Parameters["@DaysheetMonth"].Value = Int32.Parse(ViewState["UseMonth"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@DaysheetYear", SqlDbType.Int));
        objCmd.Parameters["@DaysheetYear"].Value = Int32.Parse(ViewState["UseYear"].ToString());

        objCmd.Parameters.Add(new SqlParameter("@Approved", SqlDbType.Int));
        objCmd.Parameters["@Approved"].Value = 0;

        objConn.Open();
        objCmd.ExecuteNonQuery();
        objConn.Close();

        Response.Redirect("review.aspx" + (Request.QueryString["m"] != null ? "?m=" + Request.QueryString["m"] : ""), true);
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // show in different color if minutes < 480 on a weekday
            if ((Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "MinutesForDay")) < 480) && (Convert.ToDateTime(DataBinder.Eval(e.Row.DataItem, "DateValue")).DayOfWeek != DayOfWeek.Sunday) && (Convert.ToDateTime(DataBinder.Eval(e.Row.DataItem, "DateValue")).DayOfWeek != DayOfWeek.Saturday))
            {
                e.Row.CssClass = "LessThan480";
            }

            // Lock records for editing after the Xth of the next month.
            DateTime datFirstOfCurrentMonth = new DateTime(System.DateTime.Now.Year, System.DateTime.Now.Month, 1);
            DateTime datFirstOfViewingMonth = new DateTime(datShowDate.Year, datShowDate.Month, 1);
            if ((datFirstOfCurrentMonth != datFirstOfViewingMonth) && ((datFirstOfCurrentMonth == datFirstOfViewingMonth.AddMonths(1)) && (System.DateTime.Today.Day > Convert.ToInt32(System.Configuration.ConfigurationManager.AppSettings["dayOfMonthRecordsLock"]))))
            {

                HyperLink hypDate = (HyperLink)e.Row.FindControl("hypDate");
                hypDate.NavigateUrl = "";
                hypDate.Text = "Locked";
            }
            // update total
            try
            {
                intTotal = intTotal + Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "MinutesForDay"));
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

    protected void ddMonth_SelectedIndexChanged(object sender, EventArgs e)
    {
        Response.Redirect(Page.Request.Url.LocalPath + "?m=" + ddMonth.SelectedValue.ToString(), true);
    }
}
