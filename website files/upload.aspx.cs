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
using System.IO;
using System.Text;
using System.Net;

public partial class _default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime UseDate = System.DateTime.Now.Date.AddMonths(-1);
            hypPrintSummary.NavigateUrl = System.Configuration.ConfigurationManager.AppSettings["ReportServerURL"] + "DaysheetSummary&Month=" + UseDate.Month + "&Year=" + UseDate.Year + "&rs:Command=Render&rs:Format=PDF";
        }
        lblError.Visible = false;
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        SqlConnection myConnection = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlDataAdapter myCommand = new SqlDataAdapter("EXEC spc_get_SupervisorsWithUnapproved", myConnection);
        DataSet ds = new DataSet();
        myCommand.Fill(ds, "dsSupervisorsWithUnapproved");
        ds.Tables["dsSupervisorsWithUnapproved"].DefaultView.Sort = "SupervisorName";
        DataList dlSupervisors = (DataList)FormView1.FindControl("DataList1");
        dlSupervisors.DataSource = ds.Tables["dsSupervisorsWithUnapproved"].DefaultView;
        dlSupervisors.DataBind();
        if (dlSupervisors != null)
        {
            dlSupervisors.DataSource = ds.Tables["dsSupervisorsWithUnapproved"].DefaultView;
            dlSupervisors.DataBind();
        }
    }
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        string fileExport, filePath, fileName, strLine, sql;
        FileStream objFileStream;
        StreamWriter objStreamWriter;
        SqlConnection cnn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        fileExport = System.Configuration.ConfigurationManager.AppSettings["fileExportName"];
        filePath = Server.MapPath("export");
        fileName = filePath + "\\" + fileExport;
        objFileStream = new FileStream(fileName, FileMode.Create, FileAccess.Write);
        objStreamWriter = new StreamWriter(objFileStream);
        cnn.Open();
        sql = "exec spc_get_DaysheetUpload";
        SqlCommand cmd = new SqlCommand(sql, cnn);
        SqlDataReader dr;
        dr = cmd.ExecuteReader();
        strLine = "";
        while (dr.Read())
        {
            for (int i = 0; i <= dr.FieldCount - 1; i++)
            {
                strLine = strLine + dr.GetValue(i).ToString();
            }
            objStreamWriter.WriteLine(strLine);
            strLine = "";
        }
        dr.Close();
        cnn.Close();
        objStreamWriter.Close();
        objFileStream.Close();
        try
        {
            ExecuteFTPTask();
        }
        catch (Exception ex)
        {
            lblError.Text = "Error in file upload: " + ex.Message + "Please contact an administrator for assistance.";
            lblError.Visible = true;
        }
        lblUploadComplete.Visible = true;
        FormView1.DataBind();
    }

    protected void FormView1_DataBound(object sender, EventArgs e)
    {
        Button btnUpload = (Button)FormView1.FindControl("Button1");
        Panel pnlNeedToApprove = (Panel)FormView1.FindControl("pnlNeedToApprove");
        Panel pnlUserPass = (Panel)FormView1.FindControl("pnlUserPass");
        Label status = ((Label)FormView1.Row.FindControl("lblStatus"));
        if (status.Text == "Approved")
        {
            btnUpload.Enabled = true;
            pnlNeedToApprove.Visible = false;
            pnlUserPass.Visible = true;
        }
        else
        {
            btnUpload.Enabled = false;
            pnlNeedToApprove.Visible = true;
            pnlUserPass.Visible = false;
        }
    }

    public void ExecuteFTPTask()
    {
        TextBox txtUsername = (TextBox)FormView1.FindControl("txtUsrnm");
        TextBox txtPassword = (TextBox)FormView1.FindControl("txtPsswd");
        try
        {
            StreamWriter commandStreamWriter = new StreamWriter(Server.MapPath("export/commands.txt"));
            string openCommand = "open " + System.Configuration.ConfigurationManager.AppSettings["ftpUploadServer"];
            commandStreamWriter.WriteLine(openCommand);
            commandStreamWriter.WriteLine(txtUsername.Text);
            commandStreamWriter.WriteLine(txtPassword.Text);
            string putCommand = "put " + System.Configuration.ConfigurationManager.AppSettings["fileExportName"] + " '" + System.Configuration.ConfigurationManager.AppSettings["fileExportName"] + "'";
            commandStreamWriter.WriteLine(putCommand);
            commandStreamWriter.WriteLine("quit");
            commandStreamWriter.Close();
            string uploadFilePath = Server.MapPath("export\\upload.bat");
            System.Diagnostics.ProcessStartInfo procStartInfo = new System.Diagnostics.ProcessStartInfo("cmd.exe");
            procStartInfo.UseShellExecute = false;
            procStartInfo.RedirectStandardOutput = true;
            procStartInfo.RedirectStandardInput = true;
            procStartInfo.RedirectStandardError = true;
            procStartInfo.WorkingDirectory = Server.MapPath("export\\");
            System.Diagnostics.Process commandShellProc = System.Diagnostics.Process.Start(procStartInfo);
            StreamReader uploadStreamRdr = System.IO.File.OpenText(uploadFilePath);
            StreamReader outputStreamRdr = commandShellProc.StandardOutput;
            StreamWriter inputStreamWriter = commandShellProc.StandardInput;
            while (uploadStreamRdr.Peek() != -1)
            {
                inputStreamWriter.WriteLine(uploadStreamRdr.ReadLine());
            }
            uploadStreamRdr.Close();
            inputStreamWriter.WriteLine("EXIT");
            commandShellProc.Close();
            string results = outputStreamRdr.ReadToEnd().Trim();
            inputStreamWriter.Close();
            outputStreamRdr.Close();
            string fmtStdOut = "<font face=courier size=0>{0}</font>";
            lblUploadComplete.Text = String.Format(fmtStdOut, results.Replace(System.Environment.NewLine, "<br>"));
            lblUploadComplete.Visible = true;

            if (lblUploadComplete.Text.IndexOf("Not logged in") > 0)
            {
                lblError.Text = "ERROR: Invalid Username or Password. Please verify your login information and try again.";
                lblError.Visible = true;
                File.Delete(Server.MapPath("export/commands.txt"));
            }
            else if (lblUploadComplete.Text.IndexOf("Unknown host") > 0)
            {
                lblError.Text = "ERROR: Unable to connect to upload site. Please contact an administrator for assistance.";
                lblError.Visible = true;
                File.Delete(Server.MapPath("export/commands.txt"));
            }
            else if (lblUploadComplete.Text.IndexOf("Invalid") > 0)
            {
                lblError.Text = "ERROR: An unexpected result was received from the upload function. Please contact an administrator for assistance.";
                lblError.Visible = true;
                File.Delete(Server.MapPath("export/commands.txt"));
            }
            else
            {
                lblError.Text = "Upload processed successfully!";
                lblError.Visible = true;
                File.Delete(Server.MapPath("export/commands.txt"));
            }

            File.Delete(Server.MapPath("export/commands.txt"));
        }
        catch (Exception ex)
        {
            lblError.Text = "An error occurred while processing this upload: " + ex.Message + " Please contact and administrator for assistance.";
            lblError.Visible = true;
            File.Delete(Server.MapPath("export/commands.txt"));
        }
    }

    private void RecordUploadSucess()
    {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand("spc_update_DaysheetUploadSuccess", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                cmd.ExecuteNonQuery();
            }  
        }
    }
}
