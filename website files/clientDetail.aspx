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
    CodeFile="clientDetail.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <h1>Edit Client</h1>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_Client_ForID" SelectCommandType="StoredProcedure" UpdateCommand="spc_update_Client"
        UpdateCommandType="StoredProcedure">
        <SelectParameters>
            <asp:QueryStringParameter Name="ClientID" QueryStringField="ID" Type="Int64" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="ClientID" Type="String" />
            <asp:Parameter Name="FirstName" Type="String" />
            <asp:Parameter Name="LastName" Type="String" />
            <asp:Parameter Name="BirthDate" Type="DateTime" />
            <asp:Parameter Name="CaseNumber" Type="Int32" />
            <asp:Parameter Name="ClientSSN" Type="String" />
            <asp:Parameter Name="ClientStatusID" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsClientList" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_Status" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
    <asp:DetailsView ID="DetailsView1" runat="server" DataKeyNames="ClientID" DataSourceID="SqlDataSource1"
        DefaultMode="Edit" AutoGenerateEditButton="True" OnItemUpdated="DetailsView1_ItemUpdated"
        OnItemCommand="DetailsView1_ItemCommand">
        <Fields>
            <asp:BoundField DataField="ClientID" HeaderText="SIS #" ReadOnly="True" SortExpression="ClientID" />
            <asp:BoundField DataField="FirstName" HeaderText="First Name" SortExpression="FirstName" />
            <asp:BoundField DataField="LastName" HeaderText="Last Name" SortExpression="LastName" />
            <asp:TemplateField HeaderText="Birth Date" SortExpression="BirthDate">
                <EditItemTemplate>
                    <asp:TextBox ID="txtBirthDateEdit" runat="server" Text='<%# Bind("BirthDate", "{0:d}") %>'></asp:TextBox>
                    <asp:CompareValidator ID="vBirthDate" runat="server" ErrorMessage="Birth Date must be a date value."
                        ControlToValidate="txtBirthDateEdit" ValueToCompare="12/31/2059" Type="date"
                        Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="txtBirthDateInsert" runat="server" Text='<%# Bind("BirthDate", "{0:d}") %>'></asp:TextBox>
                    <asp:CompareValidator ID="vBirthDate2" runat="server" ErrorMessage="Birth Date must be a date value."
                        ControlToValidate="txtBirthDateInsert" ValueToCompare="12/31/2059" Type="date"
                        Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label2" runat="server" Text='<%# Bind("BirthDate", "{0:d}") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Case #" SortExpression="CaseNumber">
                <EditItemTemplate>
                    <asp:TextBox ID="txtCaseNumberEdit" runat="server" Text='<%# Bind("CaseNumber") %>'></asp:TextBox>
                    <asp:RangeValidator ID="vCaseNumber" runat="server" ErrorMessage="Case # must be numeric."
                        Type="integer" MinimumValue="0" MaximumValue="999999" ControlToValidate="txtCaseNumberEdit">
                    </asp:RangeValidator>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="txtCaseNumberInsert" runat="server" Text='<%# Bind("CaseNumber") %>'></asp:TextBox>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label3" runat="server" Text='<%# Bind("CaseNumber") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Client SSN" SortExpression="ClientSSN">
                <EditItemTemplate>
                    <asp:TextBox ID="txtClientSSNEdit" runat="server" Text='<%# Bind("ClientSSN") %>'></asp:TextBox><span
                        style="font-weight: normal"> ###-##-####</span>
                    <asp:RegularExpressionValidator ID="revClientSSN" runat="server" ControlToValidate="txtClientSSNEdit"
                        ValidationExpression="^\d{3}\-\d{2}\-\d{4}$" ErrorMessage="<br />Client SSN must be in the format ###-##-####"
                        Display="dynamic" />
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="txtClientSSNInsert" runat="server" Text='<%# Bind("ClientSSN") %>'></asp:TextBox><span
                        style="font-weight: normal"> ###-##-####</span>
                    <asp:RegularExpressionValidator ID="revClientSSN" runat="server" ControlToValidate="txtClientSSNEdit"
                        ValidationExpression="^\d{3}\-\d{2}\-\d{4}$" ErrorMessage="<br />Client SSN must be in the format ###-##-####"
                        Display="dynamic" />
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label4" runat="server" Text='<%# Bind("ClientSSN") %>'></asp:Label><span
                        style="font-weight: normal"></span>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Status" SortExpression="ClientStatusID">
                <EditItemTemplate>
                    <asp:DropDownList ID="ddClientStatus" runat="server" DataSourceID="dsClientList"
                        DataTextField="ClientStatusID" DataValueField="ClientStatusID" SelectedValue='<%# Bind("ClientStatusID") %>'>
                    </asp:DropDownList>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("ClientStatusID") %>'></asp:TextBox>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label1" runat="server" Text='<%# Bind("ClientStatusID") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
        </Fields>
    </asp:DetailsView>
</asp:Content>
