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
    CodeFile="clients.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <h1>
        Clients
    </h1>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_ClientList_ForClientStatus" SelectCommandType="StoredProcedure"
        DeleteCommand="spc_delete_Client" DeleteCommandType="StoredProcedure" DataSourceMode="DataSet">
        <SelectParameters>
            <asp:ControlParameter Name="ClientStatus" ControlID="ddClientStatusFilter" Type="String" />
        </SelectParameters>
        <DeleteParameters>
            <asp:QueryStringParameter Name="ClientID" QueryStringField="ClientID" Type="Int64" />
        </DeleteParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_ClientStatus_Filter" SelectCommandType="StoredProcedure">
    </asp:SqlDataSource>
    <asp:DropDownList ID="ddClientStatusFilter" runat="server" DataSourceID="SqlDataSource2"
        DataTextField="ClientStatusID" DataValueField="ClientStatusID" AutoPostBack="True">
    </asp:DropDownList>
    <br />
    <br />
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="ClientID"
        DataSourceID="SqlDataSource1" AllowSorting="True">
        <Columns>
            <asp:HyperLinkField DataNavigateUrlFields="ClientID" DataNavigateUrlFormatString="clientDetail.aspx?ID={0}"
                DataTextField="ClientID" HeaderText="SIS #" />
            <asp:BoundField DataField="FirstName" HeaderText="First Name" SortExpression="FirstName" />
            <asp:BoundField DataField="LastName" HeaderText="Last Name" SortExpression="LastName" />
            <asp:BoundField ApplyFormatInEditMode="True" DataField="BirthDate" DataFormatString="{0:d}"
                HtmlEncode="False" HeaderText="DOB" SortExpression="BirthDate" />
            <asp:BoundField DataField="CaseNumber" HeaderText="Case #" SortExpression="CaseNumber" />
            <asp:BoundField DataField="ClientSSN" HeaderText="SSN" SortExpression="ClientSSN" />
        </Columns>
    </asp:GridView>
</asp:Content>
