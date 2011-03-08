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

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="review.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_DaysheetReview_ForSupervisor" SelectCommandType="StoredProcedure" OnSelecting="SqlDataSource1_Selecting">
        <SelectParameters>
            <asp:Parameter Name="SupervisorID" Type="String" />
            <asp:QueryStringParameter DefaultValue="0" Name="MonthAdjuster" QueryStringField="m" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    
    <h1>Review & Approve</h1>
    
    <asp:DropDownList ID="ddMonth" runat="server"  AutoPostBack="True" OnSelectedIndexChanged="ddMonth_SelectedIndexChanged">
    </asp:DropDownList><br /><br />
    
    <asp:Label ID="ErrorMessageLabel" runat="server" CssClass="errorMessage" Visible="False"></asp:Label>
    
    <asp:GridView ID="GridView1" runat="server"
        AutoGenerateColumns="False"
        DataSourceID="SqlDataSource1" DataKeyNames="DirectReportID"
        AllowSorting="False" OnDataBound="GridView1_DataBound" OnRowDataBound="GridView1_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <EditItemTemplate>
                    <asp:HyperLink 
                        NavigateUrl='<%# "month.aspx?" + ( (Request.QueryString["m"] == null) ? "" : "m=" + Request.QueryString["m"] + "&" ) + "u=" + DataBinder.Eval(Container.DataItem,"DirectReportID") %>' 
                        runat="server"
                        ID="hypDate" 
                        Text=''>
                    </asp:HyperLink>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:HyperLink 
                        NavigateUrl='<%# "month.aspx?" + ( (Request.QueryString["m"] == null) ? "" : "m=" + Request.QueryString["m"] + "&" ) + "u=" + DataBinder.Eval(Container.DataItem,"DirectReportID")  %>' 
                        runat="server"
                        ID="hypDate"
                        Text=''>
                    </asp:HyperLink>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:HyperLink 
                        NavigateUrl='<%# "month.aspx?" + ( (Request.QueryString["m"] == null) ? "" : "m=" + Request.QueryString["m"] + "&" ) + "u=" + DataBinder.Eval(Container.DataItem,"DirectReportID") %>' 
                        runat="server"
                        ID="hypDate"
                        Text='Review'>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DirectReportFullName" 
                HeaderText="Worker" 
                ItemStyle-HorizontalAlign="left" HeaderStyle-HorizontalAlign="left" />
            <asp:BoundField DataField="MinutesForMonth" 
                HeaderText="Minutes" 
                HeaderStyle-HorizontalAlign="center"
                HtmlEncode="false" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="right" 
                FooterStyle-HorizontalAlign="right" ItemStyle-CssClass="padNumericCell"
                FooterStyle-CssClass="padNumericCell" />
            <asp:BoundField DataField="Certified" 
                HeaderText="Certified" 
                ItemStyle-HorizontalAlign="center" HeaderStyle-HorizontalAlign="center" />
            <asp:BoundField DataField="Approved" 
                HeaderText="Approved" 
                ItemStyle-HorizontalAlign="center" HeaderStyle-HorizontalAlign="center" />
        </Columns>
        <FooterStyle Font-Bold="True" />
    </asp:GridView>
</asp:Content>

