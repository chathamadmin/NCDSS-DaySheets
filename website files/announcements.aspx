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

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="announcements.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <h1>
        Announcements
    </h1>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_AnnouncementList" SelectCommandType="StoredProcedure"
        DeleteCommand="spc_delete_Announcement" DeleteCommandType="StoredProcedure">
        <DeleteParameters>
            <asp:Parameter Name="AnnouncementID" Type="String" />
        </DeleteParameters>
    </asp:SqlDataSource>
    <a href="announcementDetail.aspx">Add New</a>
    <br />
    <br />
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="AnnouncementID"
        DataSourceID="SqlDataSource1" AllowSorting="True">
        <Columns>
            <asp:BoundField DataField="AnnouncementID" Visible="False" />
            <asp:TemplateField ShowHeader="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ImageButton2" runat="server" CausesValidation="False" CommandName="Delete"
                        ImageUrl="~/images/delete.png" AlternateText="Delete" />
                    <ajaxToolkit:ConfirmButtonExtender ID="cbe" runat="server" TargetControlID="ImageButton2"
                        ConfirmText="Are you sure you want to delete this Daysheet record?" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# Eval("AnnouncementID", "announcementDetail.aspx?ID={0}") %>'
                        Text="Edit" ImageUrl="~/images/edit.png"></asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DisplayFrom" HeaderText="From" SortExpression="DisplayFrom" />
            <asp:BoundField DataField="DisplayTo" HeaderText="To" SortExpression="DisplayTo" />
            <asp:BoundField DataField="AnnouncementText" HeaderText="Announcement" SortExpression="AnnouncementText" />
            <asp:BoundField DataField="ProgramCodeID_DepletionLink" HeaderText="Depletion Link"
                SortExpression="ProgramCodeID_DepletionLink" />
        </Columns>
    </asp:GridView>
</asp:Content>