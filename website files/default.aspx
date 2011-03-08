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
    CodeFile="default.aspx.cs" Inherits="_default" Title="DSS Daysheets" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_Announcements_ForToday" SelectCommandType="StoredProcedure"
        DataSourceMode="dataReader"></asp:SqlDataSource>
    <h1>Home</h1>
    <asp:Repeater ID="Repeater1" runat="server" DataSourceID="SqlDataSource1">
        <ItemTemplate>
            <div id="announcement">
                <p style="font-weight: bold;"><%# DataBinder.Eval(Container.DataItem, "Header") %></p>
                <p><%# DataBinder.Eval(Container.DataItem, "Announcement") %></p>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>
