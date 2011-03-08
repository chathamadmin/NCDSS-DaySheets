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
    CodeFile="announcementDetail.aspx.cs" Inherits="_default" Title="DSS Daysheets"
    Theme="defaultTheme" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <h1>
        Edit Announcement</h1>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_Announcement_ForID" SelectCommandType="StoredProcedure"
        UpdateCommand="spc_update_Announcement" UpdateCommandType="StoredProcedure" InsertCommand="spc_insert_Announcement"
        InsertCommandType="StoredProcedure" DeleteCommand="spc_delete_Announcement" DeleteCommandType="StoredProcedure">
        <DeleteParameters>
            <asp:Parameter Name="AnnouncementID" Type="String" />
        </DeleteParameters>
        <SelectParameters>
            <asp:QueryStringParameter Name="AnnouncementID" QueryStringField="ID" Type="Int32" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="AnnouncementID" Type="String" />
            <asp:Parameter Name="AnnouncementText" Type="String" />
            <asp:Parameter Name="DisplayFrom" Type="DateTime" />
            <asp:Parameter Name="DisplayTo" Type="DateTime" />
            <asp:Parameter Name="ProgramCodeID_DepletionLink" Type="String" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="AnnouncementText" Type="String" />
            <asp:Parameter Name="DisplayFrom" Type="DateTime" />
            <asp:Parameter Name="DisplayTo" Type="DateTime" />
            <asp:Parameter Name="ProgramCodeID_DepletionLink" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsDepletionLink" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_DepletionLink" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:DetailsView ID="DetailsView1" runat="server" DataKeyNames="AnnouncementID" DataSourceID="SqlDataSource1"
        DefaultMode="Insert" AutoGenerateEditButton="True" CommandRowStyle-CssClass="CommandRow"
        AutoGenerateInsertButton="True" OnItemUpdated="DetailsView1_ItemUpdated" OnItemCommand="DetailsView1_ItemCommand"
        OnItemInserted="DetailsView1_ItemInserted">
        <Fields>
            <asp:BoundField DataField="AnnouncementID" Visible="False" />
            <asp:TemplateField HeaderText="Announcement" SortExpression="AnnouncementText">
                <EditItemTemplate>
                    <asp:TextBox ID="TextBox1" runat="server" Wrap="True" TextMode="MultiLine" Text='<%# Bind("AnnouncementText") %>'></asp:TextBox>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="TextBox1" runat="server" Wrap="True" TextMode="MultiLine" Text='<%# Bind("AnnouncementText") %>'></asp:TextBox>
                </InsertItemTemplate>
                <ControlStyle Height="60px" Width="450px" />
                <ItemTemplate>
                    <asp:Label ID="Label2" runat="server" Text='<%# Bind("AnnouncementText") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Display From" SortExpression="DisplayFrom">
                <EditItemTemplate>
                    <asp:TextBox ID="txtFromEdit" runat="server" Text='<%# Bind("DisplayFrom", "{0:d}") %>'></asp:TextBox>
                    <ajaxToolkit:CalendarExtender ID="calFromEdit" runat="server" TargetControlID="txtFromEdit" />
                    <asp:RequiredFieldValidator ID="vFromRequired" runat="server" ErrorMessage="Display From is a required field."
                        ControlToValidate="txtFromEdit" Display="dynamic" SetFocusOnError="true">
                    </asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="vFromEdit" runat="server" ErrorMessage="Display From must be a date value."
                        Display="dynamic" ControlToValidate="txtFromEdit" ValueToCompare="12/31/2059"
                        Type="date" Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="txtFromInsert" runat="server" Text='<%# Bind("DisplayFrom", "{0:d}") %>'></asp:TextBox>
                    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromInsert" />
                    <asp:RequiredFieldValidator ID="vFromRequired" runat="server" ErrorMessage="Display From is a required field."
                        ControlToValidate="txtFromInsert" Display="Dynamic" SetFocusOnError="true">
                    </asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="vFromInsert" runat="server" ErrorMessage="Display From must be a date value."
                        ControlToValidate="txtFromInsert" Display="dynamic" ValueToCompare="12/31/2059"
                        Type="date" Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label3" runat="server" Text='<%# Bind("DisplayFrom", "{0:d}") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Display To" SortExpression="DisplayTo">
                <EditItemTemplate>
                    <asp:TextBox ID="txtToEdit" runat="server" Text='<%# Bind("DisplayTo", "{0:d}") %>'></asp:TextBox>
                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToEdit" />
                    <asp:RequiredFieldValidator ID="vToRequired" runat="server" ErrorMessage="Display To is a required field."
                        ControlToValidate="txtToEdit" Display="Dynamic" SetFocusOnError="true">
                    </asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="vToEdit" runat="server" ErrorMessage="Display To must be a date value."
                        ControlToValidate="txtToEdit" Display="dynamic" ValueToCompare="12/31/2059" Type="date"
                        Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:TextBox ID="txtToInsert" runat="server" Text='<%# Bind("DisplayTo", "{0:d}") %>'></asp:TextBox>
                    <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtToInsert" />
                    <asp:RequiredFieldValidator ID="vToRequired" runat="server" ErrorMessage="Display To is a required field."
                        ControlToValidate="txtToInsert" Display="Dynamic" SetFocusOnError="true">
                    </asp:RequiredFieldValidator>
                    <asp:CompareValidator ID="vToInsert" runat="server" ErrorMessage="Display To must be a date value."
                        ControlToValidate="txtToInsert" Display="dynamic" ValueToCompare="12/31/2059"
                        Type="date" Operator="lessThanEqual" SetFocusOnError="true"></asp:CompareValidator>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label4" runat="server" Text='<%# Bind("DisplayTo", "{0:d}") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Depletion Link" SortExpression="ProgramCodeID_DepletionLink">
                <EditItemTemplate>
                    <asp:DropDownList ID="ddDepletionLink" runat="server" DataSourceID="dsDepletionLink"
                        DataTextField="DepletionLink" DataValueField="ProgramCodeID" SelectedValue='<%# Bind("ProgramCodeID_DepletionLink") %>'>
                    </asp:DropDownList>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:DropDownList ID="ddDepletionLink" runat="server" DataSourceID="dsDepletionLink"
                        DataTextField="DepletionLink" DataValueField="ProgramCodeID" SelectedValue='<%# Bind("ProgramCodeID_DepletionLink") %>'>
                    </asp:DropDownList>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label1" runat="server" Text='<%# Bind("ProgramCodeID_DepletionLink") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
        </Fields>
    </asp:DetailsView>
</asp:Content>
