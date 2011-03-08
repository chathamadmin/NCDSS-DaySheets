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
using System.Diagnostics;

public partial class _default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
           
        }
    }



    protected void btnSingleClientIDUpload_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;

        if (tbClientID.Text.Trim() != "")
            try
            {
                InsertSingleClientID(tbClientID.Text.Trim());
                string destinationPage = "clientDetail.aspx?ID=" + tbClientID.Text.Trim();
                Response.Redirect(destinationPage);
            }
            catch (Exception ex)
            {
                lblError.Text = "Please enter a valid client ID.";
                lblError.Visible = true;             
            }
        else
        {
            lblError.Text = "Please enter a valid client ID.";
            lblError.Visible = true;
        }
    }


    protected void btnUpload_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;

        if (FileUpload1.HasFile)
            try
            {
                FileUpload1.SaveAs(Server.MapPath("data\\SISNumberUpload.txt"));
                lblError.Text = "File name: " +
                     FileUpload1.PostedFile.FileName + "<br>" +
                     FileUpload1.PostedFile.ContentLength + " kb<br>" +
                     "Content type: " +
                     FileUpload1.PostedFile.ContentType;

                ImportClientIDs();
            }
            catch (Exception ex)
            {
                lblError.Text = "ERROR: " + ex.Message.ToString();
                lblError.Visible = true;               
            }
        else
        {
            lblError.Text = "You have not specified a file.";
            lblError.Visible = true;
        }
    }

    private void ImportClientIDs()
    {
        Stopwatch sw = new Stopwatch();
        sw.Start();
        SqlBulkCopy bulkCopy = new SqlBulkCopy(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString,
            SqlBulkCopyOptions.TableLock);
        bulkCopy.DestinationTableName = "dbo.Import_ClientID";
        bulkCopy.WriteToServer(CreateDataTableFromFile());
        sw.Stop();

        ProcessClientIDs();

        lblError.Text = "Import successful (" + (sw.ElapsedMilliseconds / 1000.00).ToString() + " seconds)";
        lblError.Visible = true;
    }

    private DataTable CreateDataTableFromFile()
    {
        DataTable dt = new DataTable();
        DataColumn dc;
        DataRow dr;

        dc = new DataColumn();
        dc.DataType = System.Type.GetType("System.Int64");
        dc.ColumnName = "ClientID";
        dc.Unique = true;
        dt.Columns.Add(dc);

        StreamReader sr = new StreamReader(Server.MapPath("data//SISNumberUpload.txt"));
        string input;
        while ((input = sr.ReadLine()) != null)
        {
            try
            {
                string[] s = input.Split(new char[] { '|' });
                dr = dt.NewRow();
                dr["ClientID"] = s[0];
                dt.Rows.Add(dr);
            }
            catch
            {
            }
        }
        sr.Close();
        return dt;
    }

    private void ProcessClientIDs()
    {
        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand();

        cmd.CommandText = "spc_action_ProcessClientIDs";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = conn;

        conn.Open();
        cmd.ExecuteNonQuery();
        conn.Close();
    }

    private void InsertSingleClientID(string ClientID)
    {
        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["DSSDaysheetConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand();

        cmd.CommandText = "spc_insert_SingleClientID";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = conn;
        SqlParameter param;
        param = cmd.Parameters.Add("@ClientID", SqlDbType.BigInt);
        param.Value = Convert.ToInt64(ClientID);
        conn.Open();
        cmd.ExecuteNonQuery();
        conn.Close();
    }
}
