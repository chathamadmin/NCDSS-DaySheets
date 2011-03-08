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
    CodeFile="month.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_DaysheetMonth_ForUser" SelectCommandType="StoredProcedure"
        OnSelecting="SqlDataSource1_Selecting" DataSourceMode="dataReader">
        <SelectParameters>
            <asp:Parameter Name="UserID" Type="String" />
            <asp:QueryStringParameter DefaultValue="0" Name="MonthAdjuster" QueryStringField="m"
                Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsUserDetails" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_UserDetails_ForUserID" SelectCommandType="StoredProcedure"
        OnSelecting="dsUserDetails_Selecting" DataSourceMode="dataReader">
        <SelectParameters>
            <asp:Parameter Name="UserID" Type="string" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:FormView ID="FormView1" runat="server" DataSourceID="dsUserDetails">
        <ItemTemplate>
            <h1>
                <%= GetDateHeader() %>
                -
                <%# Eval("FullName") %></h1>
        </ItemTemplate>
    </asp:FormView>
    <asp:DropDownList ID="ddMonth" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddMonth_SelectedIndexChanged">
    </asp:DropDownList>
    <br />
    <br />
    <asp:Label ID="ErrorMessageLabel" runat="server" CssClass="errorMessage" Visible="False"></asp:Label>
    <asp:HyperLink runat="server" ID="hypPrintMonth" Text="Print Month" Target=""></asp:HyperLink><br />
    <br />
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1"
        DataKeyNames="DateValue" AllowSorting="False" OnRowDataBound="GridView1_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <EditItemTemplate>
                    <asp:HyperLink NavigateUrl='<%# "daysheet.aspx?Date=" +
                            String.Format("{0:mmddyyyy}", DataBinder.Eval(Container.DataItem,"DateValue")) %>'
                        runat="server" ID="hypDate" Text='<%# String.Format("{0:d}", DataBinder.Eval(Container.DataItem,"DateValue")) %>'>
                    </asp:HyperLink>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <asp:HyperLink NavigateUrl='<%# "daysheet.aspx?Date=" +
                            String.Format("{0:mmddyyyy}", DataBinder.Eval(Container.DataItem,"DateValue")) %>'
                        runat="server" ID="hypDate" Text='<%# String.Format("{0:d}", DataBinder.Eval(Container.DataItem,"DateValue")) %>'>
                    </asp:HyperLink>
                </InsertItemTemplate>
                <ItemTemplate>
                    <asp:HyperLink NavigateUrl='<%# "daysheet.aspx?d=" +
                            Server.UrlEncode(String.Format("{0:d}", DataBinder.Eval(Container.DataItem,"DateValue"))) +
                            ( Request.QueryString["u"] != null ? "&u=" + Request.QueryString["u"] : "" ) %>'
                        runat="server" ID="hypDate" Text='Edit Daysheet'>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:HyperLinkField DataNavigateUrlFields="DateValue" DataNavigateUrlFormatString="daysheetDetail.aspx?d={0}"
                DataTextField="DateValue" HeaderText="Date" DataTextFormatString="{0:D}" />
            <asp:BoundField DataField="MinutesForDay" HeaderText="Minutes" HeaderStyle-HorizontalAlign="center"
                DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="right" ItemStyle-CssClass="padNumericCell"
                HtmlEncode="false" FooterStyle-HorizontalAlign="right" FooterStyle-CssClass="padNumericCell" />
        </Columns>
        <FooterStyle Font-Bold="True" />
    </asp:GridView>
    <br />
    <asp:MultiView ID="mvCertifyApprove" runat="server" ActiveViewIndex="0">
        <asp:View ID="vwSelfNotCertified" runat="server">
            I certify that the daysheet entries for this month are both complete and accurate.<br />
            <br />
            <asp:Button runat="server" ID="btnCertify" Text="Certify Month" OnClick="btnCertify_Click" />
        </asp:View>
        <asp:View ID="vwSelfCertified" runat="server">
            This daysheet has been certified.<br />
            <br />
            <asp:Button runat="server" ID="btnUncertify" Text="Undo Certification" OnClick="btnUncertify_Click" />
        </asp:View>
        <asp:View ID="vwSupervisorNotCertified" runat="server">
            This daysheet month has not yet been certified by the user.
            <br />
            <br />
            <asp:Button runat="server" ID="Button1" Text="Certify Only" OnClick="btnCertify_Click" />
            <asp:Button runat="server" ID="Button3" Text="Certify & Approve" OnClick="btnCertifyAndApprove_Click" />
        </asp:View>
        <asp:View ID="vwSupervisorNotApproved" runat="server">
            This daysheet month has been certified, but not approved.
            <br />
            <br />
            <asp:Button runat="server" ID="Button2" Text="Approve Month" OnClick="btnApprove_Click" />
        </asp:View>
        <asp:View ID="vwSupervisorApproved" runat="server">
            This daysheet month has been certified and approved.<br />
            <br />
            <asp:Button runat="server" ID="Button4" Text="Undo Certification & Approval" OnClick="btnUndoCertifyAndApprove_Click" />
        </asp:View>
    </asp:MultiView>
</asp:Content>
