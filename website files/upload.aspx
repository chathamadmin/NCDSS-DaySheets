<%-- This file is part of NCDSS Daysheets.

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
--%>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="upload.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="DefaultTheme" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
   SelectCommand="spc_get_UploadDetails" SelectCommandType="StoredProcedure">
   <SelectParameters>
        <asp:Parameter DefaultValue="-1" Name="MonthAdjuster" Type="int32" />
   </SelectParameters>
</asp:SqlDataSource>
    <h1>Upload</h1>
    
    <asp:HyperLink runat="server" ID="hypPrintSummary" Text="Print Summary Report" Target=""></asp:HyperLink>
    <asp:FormView ID="FormView1" runat="server" DataSourceID="SqlDataSource1" OnDataBound="FormView1_DataBound">
        <ItemTemplate>
        <div id="announcement">
            <table>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblUploadMonth" runat="server" Text='<%# Eval("UploadMonth") %>' 
                            Font-Bold="true" Font-Size="16px" EnableTheming="false" ></asp:Label>
                    </td>
                </tr>
                <tr><td colspan="2">&nbsp;</td></tr>
                <tr>
                    <td style="width:100px; vertical-align: top; height: 20px;">Data Status:</td>
                    <td style="width:400px; vertical-align: top; "><asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status")%>'></asp:Label>
                    </td>
                </tr>
                <asp:Panel runat="server" ID="pnlNeedToApprove" Visible="false">
                <tr>
                    <td style="width:100px; vertical-align: top; ">&nbsp;</td>
                    <td style="width:400px; vertical-align: top;">
                        <asp:DataList ID="DataList1" runat="server" RepeatColumns="2">
                            <ItemTemplate>
                                &nbsp;&nbsp;-&nbsp;<%# DataBinder.Eval(Container.DataItem, "SupervisorName") %>
                            </ItemTemplate>
                        </asp:DataList>
                        <br />
                    </td>
                </tr>
                </asp:Panel>
                <tr>
                    <td style="width:100px; vertical-align: top; height: 20px;">Last Upload:</td>
                    <td style="width:400px; vertical-align: top;"><asp:Label ID="lblLastUpload" runat="server" Text='<%# Eval("LastUpload")%>'></asp:Label></td>
                </tr>
                <asp:Panel runat="server" ID="pnlUserPass">
                <tr>
                    <td style="width:100px; vertical-align: top; height: 20px;">Username:</td>
                    <td style="width:400px; vertical-align: top;">
                        <asp:TextBox runat="server" ID="txtUsrnm"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td style="width:100px; vertical-align: top; height: 20px;">Password:</td>
                    <td style="width:400px; vertical-align: top;">
                        <asp:TextBox runat="server" ID="txtPsswd" TextMode="Password"></asp:TextBox>
                    </td>
                </tr>
                </asp:Panel>
                <tr><td colspan="2">&nbsp;</td></tr>
                <tr>
                    <td colspan="2">
                        <asp:Button runat="server" ID="Button1" Text="Upload Now" OnClick="btnUpload_Click"  /> 
                    </td>
                </tr>
            </table>
        </div>
        </ItemTemplate>
    </asp:FormView>
    <asp:Label runat="server" ID="lblError" Text="An error occurred while processing the upload. Please contact Michael Bradley at 919-542-8286." Visible="false" CssClass="errorMessage"></asp:Label>
    <br /><br />
    <asp:Label runat="server" ID="lblUploadComplete" Text="Upload Complete!" Visible="false"></asp:Label>    
</asp:Content>

