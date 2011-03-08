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

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="sisUpload.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>SIS # Upload</h1>
    
    <asp:Label ID="lblError" runat="server" Visible="false"></asp:Label>
    <br /><br />
   
     <table class="detailsView" style="padding:20px;">
        <tr class="detailsViewRow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="detailsViewRow">
             <h3>Single Client ID Upload: </h3>
             <td colspan="2">&nbsp&nbsp Client ID: <asp:TextBox ID="tbClientID" runat="server" Width="120" MaxLength="11" /></td>
        </tr>
        <tr class="detailsViewRow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="detailsViewRow">
            <td colspan="2" align="right">
                <asp:Button runat="server" ID="btnSingleClientIDUpload" style="margin:0 10px 10px 0;"
                    OnClick="btnSingleClientIDUpload_Click" Text="Upload Single Client ID" />
            </td>
        </tr>
    </table>
    <br />
    <br />

    <table class="detailsView">
        <tr class="detailsViewRow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="detailsViewRow">
        <h3>Bulk Client ID Upload: </h3>
            <td>&nbsp&nbsp Text File: </td>
            <td><asp:FileUpload ID="FileUpload1" runat="server" Width="400" /></td>
        </tr>
        <tr class="detailsViewRow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="detailsViewRow">
            <td colspan="2" align="right">
                <asp:Button runat="server" ID="btnUpload" style="margin:0 10px 10px 0;"
                    OnClick="btnUpload_Click" Text="Bulk Upload" />
            </td>
        </tr>
    </table>
    
</asp:Content>

