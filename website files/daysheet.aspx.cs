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
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            MasterPage myMaster = (MasterPage)this.Master;
            myMaster.CheckLogin();
            CheckViewState();
            SetEligibilityQuestionsCheckbox();
            SetNextDayLink();
        }
        else
        {
            ErrorMessageLabel.Visible = false;
        }
        // hide the data entry screen if record is locked
        DateTime datDaysheetDate = GetDaysheetDate();
        DateTime datFirstOfCurrentMonth = new DateTime(System.DateTime.Now.Year, System.DateTime.Now.Month, 1);
        DateTime datFirstOfViewingMonth = new DateTime(datDaysheetDate.Year, datDaysheetDate.Month, 1);
        if ((datFirstOfCurrentMonth != datFirstOfViewingMonth) && ((datFirstOfCurrentMonth == datFirstOfViewingMonth.AddMonths(1)) && (System.DateTime.Today.Day > 6)))
        {
            FormViewMain.Visible = false;
            chkShowEligibilityQuestions.Visible = false;
            lblLocked.Visible = true;
        }
    }

    protected void SetNextDayLink()
    {
        DateTime datDaysheetDate = GetDaysheetDate();
        if (Request.QueryString["u"] != null)
        {
            if (datDaysheetDate != System.DateTime.Today)
            {
                if (datDaysheetDate.Month != datDaysheetDate.AddDays(1).Month)
                {
                    hypNextPage.NavigateUrl = "review.aspx?m=" + (datDaysheetDate.Month == System.DateTime.Today.Month ? "0" : "-1");
                }
                else
                    hypNextPage.NavigateUrl = Page.Request.Url.LocalPath + "?d=" + datDaysheetDate.AddDays(1).ToShortDateString() + "&u=" + Request.QueryString["u"];
                hypNextPage.Enabled = true;
                hypNextPage.CssClass = null;
            }
            else
            {
                hypNextPage.Enabled = false;
                hypNextPage.CssClass = "disabled";
            }
        }
        else
        {
            hypNextPage.Visible = false;
        }
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

    protected void SetEligibilityQuestionsCheckbox()
    {
        if (Session["ShowEligibilityQuestions"] == null)
        {
            // NEED TO CODE - retrieve from prefs
            Session["ShowEligibilityQuestions"] = false;
        }
        chkShowEligibilityQuestions.Checked = Boolean.Parse(Session["ShowEligibilityQuestions"].ToString());
    }

    protected void UpdateEligibilitySession(object sender, EventArgs e)
    {
        Session["ShowEligibilityQuestions"] = chkShowEligibilityQuestions.Checked;
    }

    protected DateTime GetDaysheetDate()
    {
        DateTime daysheetDate = System.DateTime.Today;
        if (Request.QueryString["d"] != null)
        {
            daysheetDate = DateTime.Parse(Server.UrlDecode(Request.QueryString["d"]));
        }
        else
        {
            daysheetDate = System.DateTime.Today;
        }
        return daysheetDate;
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            try
            {
                // add to total
                ViewState["intTotal"] = Int32.Parse(ViewState["intTotal"].ToString()) + Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "Minutes"));
                // hide edit and delete controls if record is locked
                DateTime datDaysheetDate = GetDaysheetDate();
                DateTime datFirstOfCurrentMonth = new DateTime(System.DateTime.Now.Year, System.DateTime.Now.Month, 1);
                DateTime datFirstOfViewingMonth = new DateTime(datDaysheetDate.Year, datDaysheetDate.Month, 1);
                if ((datFirstOfCurrentMonth != datFirstOfViewingMonth) && ((datFirstOfCurrentMonth == datFirstOfViewingMonth.AddMonths(1)) && (System.DateTime.Today.Day > Convert.ToInt32(System.Configuration.ConfigurationManager.AppSettings["dayOfMonthRecordsLock"]))))
                {
                    ImageButton imgEdit = (ImageButton)e.Row.FindControl("imgEdit");
                    ImageButton imgDelete = (ImageButton)e.Row.FindControl("imgDelete");
                    imgEdit.Visible = false;
                    imgDelete.Visible = false;
                }
            }
            catch
            {
            }
        }
        else if (e.Row.RowType == DataControlRowType.Footer)
        {
            if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
            {
                e.Row.Cells[6].Text = "Total:";
                e.Row.Cells[7].Text = ((int)ViewState["intTotal"]).ToString("N0");
            }
            else
            {
                e.Row.Cells[5].Text = "Total:";
                e.Row.Cells[7].Text = ((int)ViewState["intTotal"]).ToString("N0");
            }
            // hide edit and delete Remainder ot GA if record is locked
            DateTime datDaysheetDate = GetDaysheetDate();
            DateTime datFirstOfCurrentMonth = new DateTime(System.DateTime.Now.Year, System.DateTime.Now.Month, 1);
            DateTime datFirstOfViewingMonth = new DateTime(datDaysheetDate.Year, datDaysheetDate.Month, 1);
            if ((datFirstOfCurrentMonth != datFirstOfViewingMonth) && ((datFirstOfCurrentMonth == datFirstOfViewingMonth.AddMonths(1)) && (System.DateTime.Today.Day > Convert.ToInt32(System.Configuration.ConfigurationManager.AppSettings["dayOfMonthRecordsLock"]))))
            {
                LinkButton RemainderToGAButton = (LinkButton)e.Row.FindControl("RemainderToGAButton");
                RemainderToGAButton.Visible = false;
            }
        }
    }

    protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
    {
        FormViewMain.ChangeMode(FormViewMode.Edit);
        FormViewMain.DataBind();
        gvGreen.DataBind();
    }

    protected void GridView1_Sorted(object sender, EventArgs e)
    {
        FormViewMain.ChangeMode(FormViewMode.Insert);
    }

    protected void GridView1_DataBinding(object sender, EventArgs e)
    {
        ViewState["intTotal"] = 0;
    }

    protected void ddDaysheetStyle_SelectedIndexChanged(object sender, EventArgs e)
    {
        FormViewMain.ChangeMode(FormViewMode.Insert);
        SetProgramCodeDropdown();
        SetDaysheetStyle();
    }

    protected void SetProgramCodeDropdown()
    {
        DropDownList ddProgramCodeGreen = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
        DropDownList ddProgramCodeWhite = (DropDownList)FormViewMain.Row.FindControl("ddProgramCodesWhite");
        RequiredFieldValidator rvProgramCode = (RequiredFieldValidator)FormViewMain.Row.FindControl("vProgramCode");
        Label lblProgramCode = (Label)FormViewMain.Row.FindControl("lblProgramCode");
        if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
        {
            ddProgramCodeGreen.Visible = true;
            ddProgramCodeWhite.Visible = false;
            rvProgramCode.ControlToValidate = "ddlProgramCodes";

            // handle Service Code / Program Code
            Label lblServiceCode = (Label)FormViewMain.Row.FindControl("lblServiceCode");
            AjaxControlToolkit.CascadingDropDown cdd = (AjaxControlToolkit.CascadingDropDown)FormViewMain.Row.FindControl("CascadingDropDown1");

            DropDownList ddServiceCode = (DropDownList)FormViewMain.Row.FindControl("ddlServiceCodes");
            if (lblServiceCode != null && !(lblServiceCode.Text.Equals("")))
                ddServiceCode.SelectedValue = lblServiceCode.Text;

            if (lblProgramCode != null && !(lblProgramCode.Text.Equals("")))
                cdd.SelectedValue = lblProgramCode.Text;
            else
                if (cdd != null)
                    cdd.SelectedValue = "";
        }
        else
        {
            ddProgramCodeGreen.Visible = false;
            ddProgramCodeWhite.Visible = true;
            rvProgramCode.ControlToValidate = "ddProgramCodesWhite";
            if (lblProgramCode != null && !(lblProgramCode.Text.Equals("")))
                ddProgramCodeWhite.SelectedValue = lblProgramCode.Text;
        }
    }

    protected void SetDaysheetStyle()
    {
        Panel pnlSISNumber;
        pnlSISNumber = (Panel)FormViewMain.FindControl("pnlSISNumber");
        Panel pnlCaseName;
        pnlCaseName = (Panel)FormViewMain.FindControl("pnlCaseName");
        Panel pnlServiceCode;
        pnlServiceCode = (Panel)FormViewMain.FindControl("pnlServiceCode");
        // now set up for appropriate daysheet style
        if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
        {
            pnlSISNumber.Visible = true;
            pnlCaseName.Visible = false;
            pnlServiceCode.Visible = true;
            panelEligibilityQuestions.Visible = true;
            gvGreen.Columns[3].Visible = true;  // Client Name (SIS #)
            gvGreen.Columns[4].Visible = false; // Case Name
            gvGreen.Columns[5].Visible = true;  // Service Code

            // DropDownList ddlServiceCodes = (DropDownList)FormViewMain.Row.FindControl("ddlServiceCodes");
            // ddlServiceCodes.Attributes.Add("OnChange", "EligibilityQuestions(this)");
            DropDownList ddlProgramCodes = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
            ddlProgramCodes.Attributes.Add("onfocus", "EligibilityQuestions(this)");
            ddlProgramCodes.Attributes.Add("onchange", "CheckForOverride(this)");
        }
        else
        {
            pnlSISNumber.Visible = false;
            pnlCaseName.Visible = true;
            pnlServiceCode.Visible = false;
            panelEligibilityQuestions.Visible = false;
            gvGreen.Columns[3].Visible = false;  // Client Name (SIS #)
            gvGreen.Columns[4].Visible = true; // Case Name
            gvGreen.Columns[5].Visible = false;  // Service Code
        }
    }

    protected void dsGridViewGreen_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@DaysheetDate"].Value = GetDaysheetDate().ToString();
        e.Command.Parameters["@DaysheetStyleID"].Value = ddDaysheetStyle.SelectedItem.ToString();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void dsProgramCodeList_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        e.Command.Parameters["@DaysheetStyleID"].Value = ddDaysheetStyle.SelectedItem.ToString();
    }

    public override void Validate()
    {
        RequiredFieldValidator vSISNumber;
        vSISNumber = (RequiredFieldValidator)FormViewMain.FindControl("vSISNumber");
        RequiredFieldValidator vServiceCode;
        vServiceCode = (RequiredFieldValidator)FormViewMain.FindControl("vServiceCode");
        DropDownList ddServiceCode;
        ddServiceCode = (DropDownList)FormViewMain.FindControl("ddlServiceCodes");
        HiddenField hdnProgramCode = (HiddenField)FormViewMain.Row.FindControl("hdnProgramCode");
        HiddenField hdnOverrideEQ = (HiddenField)FormViewMain.Row.FindControl("hdnOverrideEQ");
        RequiredFieldValidator vProgramCode = (RequiredFieldValidator)FormViewMain.FindControl("vProgramCode");
        if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
        {
            if (ddServiceCode.SelectedValue != null && !(ddServiceCode.SelectedValue.ToString().Equals("")))
                vSISNumber.Enabled = (int.Parse(ddServiceCode.SelectedValue.ToString().Substring(0, 1)) == 1);
            else
                vSISNumber.Enabled = false;
            vServiceCode.Enabled = true;

            if (hdnProgramCode.Value != null && hdnProgramCode.Value != "" && hdnOverrideEQ.Value == "0")
                vProgramCode.Enabled = false;
            else
                vProgramCode.Enabled = true;
        }
        else
        {
            vSISNumber.Enabled = false;
            vServiceCode.Enabled = false;
        }
        base.Validate();
    }

    protected void dsUserDetails_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void dsDaysheetStyle_ForUser_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void FormViewMain_ItemInserted(object sender, FormViewInsertedEventArgs e)
    {
        if (e.Exception != null)
        {
            ErrorMessageLabel.Text = "Unable to insert record. " + e.Exception.Message.ToString();
            ErrorMessageLabel.Visible = true;
            e.ExceptionHandled = true;
        }
        gvGreen.DataBind();
    }

    protected void FormViewMain_ItemUpdated(object sender, FormViewUpdatedEventArgs e)
    {
        if (e.Exception != null)
        {
            ErrorMessageLabel.Text = "Unable to update record. " + e.Exception.Message.ToString();
            ErrorMessageLabel.Visible = true;
            e.ExceptionHandled = true;
        }
        gvGreen.DataBind();
    }

    protected void FormViewMain_DataBound(object sender, EventArgs e)
    {
        SetDaysheetStyle();
        SetProgramCodeDropdown();
        LinkButton lnkUpdate = (LinkButton)FormViewMain.Row.FindControl("FormViewUpdateButton");
        lnkUpdate.Visible = (FormViewMain.CurrentMode.ToString() == "Edit");
        LinkButton lnkInsert = (LinkButton)FormViewMain.Row.FindControl("FormViewInsertButton");
        lnkInsert.Visible = (FormViewMain.CurrentMode.ToString() == "Insert");
        FormViewMain.Focus();
    }

    protected void FormViewMain_ItemInserting(object sender, FormViewInsertEventArgs e)
    {
        SetProgramCodeDropdown();
        Label lblProgramCode = (Label)FormViewMain.Row.FindControl("lblProgramCode");
        DropDownList ddProgramCode = new DropDownList();
        if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
        {
            HiddenField hdnProgramCode = (HiddenField)FormViewMain.Row.FindControl("hdnProgramCode");
            HiddenField hdnOverrideEQ = (HiddenField)FormViewMain.Row.FindControl("hdnOverrideEQ");
            if (hdnProgramCode.Value != null && hdnProgramCode.Value != "" && hdnOverrideEQ.Value == "0")
            {
                lblProgramCode.Text = hdnProgramCode.Value;
            }
            else
            {
                ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
                lblProgramCode.Text = ddProgramCode.SelectedValue;
            }
        }
        else
        {
            ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddProgramCodesWhite");
            lblProgramCode.Text = ddProgramCode.SelectedValue;
        }
        e.Values["ProgramCodeID"] = lblProgramCode.Text;
        Label lblServiceCode = (Label)FormViewMain.Row.FindControl("lblServiceCode");
        DropDownList ddServiceCode = (DropDownList)FormViewMain.Row.FindControl("ddlServiceCodes");
        lblServiceCode.Text = ddServiceCode.SelectedValue;
        e.Values["ServiceCodeWithClientIDFlag"] = lblServiceCode.Text;
    }

    protected void FormViewMain_ItemUpdating(object sender, FormViewUpdateEventArgs e)
    {
        Label lblProgramCode = (Label)FormViewMain.Row.FindControl("lblProgramCode");
        DropDownList ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
        if (ddDaysheetStyle.SelectedItem.ToString().Equals("Green"))
        {
            HiddenField hdnProgramCode = (HiddenField)FormViewMain.Row.FindControl("hdnProgramCode");
            ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
            HiddenField hdnOverrideEQ = (HiddenField)FormViewMain.Row.FindControl("hdnOverrideEQ");
            if (hdnProgramCode.Value != null && hdnProgramCode.Value != "" && hdnOverrideEQ.Value == "0")
            {
                lblProgramCode.Text = hdnProgramCode.Value;
            }
            else
            {
                ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddlProgramCodes");
                lblProgramCode.Text = ddProgramCode.SelectedValue;
            }
        }
        else
        {
            ddProgramCode = (DropDownList)FormViewMain.Row.FindControl("ddProgramCodesWhite");
            lblProgramCode.Text = ddProgramCode.SelectedValue;
        }
        e.NewValues["ProgramCodeID"] = lblProgramCode.Text;
        Label lblServiceCode = (Label)FormViewMain.Row.FindControl("lblServiceCode");
        DropDownList ddServiceCode = (DropDownList)FormViewMain.Row.FindControl("ddlServiceCodes");
        lblServiceCode.Text = ddServiceCode.SelectedValue;
        e.NewValues["ServiceCodeWithClientIDFlag"] = lblServiceCode.Text;
    }

    protected void dsDetailsMain_Inserting(object sender, SqlDataSourceCommandEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@DaysheetDate"].Value = GetDaysheetDate().ToString();
        e.Command.Parameters["@DaysheetStyleID"].Value = ddDaysheetStyle.SelectedItem.ToString();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void dsDetailsMain_Updating(object sender, SqlDataSourceCommandEventArgs e)
    {
        CheckViewState();
        e.Command.Parameters["@DaysheetDate"].Value = GetDaysheetDate().ToString();
        e.Command.Parameters["@DaysheetStyleID"].Value = ddDaysheetStyle.SelectedItem.ToString();
        e.Command.Parameters["@UserID"].Value = ViewState["DaysheetUserID"];
    }

    protected void RemainderToGA(object sender, EventArgs e)
    {
        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand();
        SqlParameter param;
        cmd.CommandText = "spc_insert_RemainderToGA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = conn;
        param = cmd.Parameters.Add("@DaysheetDate", SqlDbType.DateTime);
        param.Value = GetDaysheetDate().ToString(); ;
        param = cmd.Parameters.Add("@UserID", SqlDbType.NVarChar, 50);
        param.Value = ViewState["DaysheetUserID"].ToString();
        param = cmd.Parameters.Add("@DaysheetStyle", SqlDbType.NVarChar, 50);
        param.Value = ddDaysheetStyle.SelectedItem.ToString();
        conn.Open();
        cmd.ExecuteNonQuery();
        conn.Close();
        gvGreen.DataBind();
    }

    protected void ods_ProgramCodes_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
    {
        e.InputParameters["DaysheetStyleID"] = ddDaysheetStyle.SelectedItem.ToString();
    }

    protected void ddlServiceCodes_SelectedIndexChanged(object sender, EventArgs e)
    {
        // set value of Service Code text box
        Label lblServiceCode = (Label)FormViewMain.Row.FindControl("lblServiceCode");
        DropDownList ddServiceCode = (DropDownList)FormViewMain.Row.FindControl("ddlServiceCodes");
        lblServiceCode.Text = ddServiceCode.SelectedValue;
    }
}
