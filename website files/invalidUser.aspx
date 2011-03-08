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

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="invalidUser.aspx.cs" Inherits="_default" 
    Title="DSS Daysheets" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h1>Invalid User</h1>
    <p>'<%= User.Identity.Name.ToString() %>' is not a valid user in the DaySheet database. </p>
    <p>If you feel you have received this message in error, please contact the database administrator to be added to the system. </p>
</asp:Content>

