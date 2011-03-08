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
    CodeFile="daysheet.aspx.cs" Inherits="_default" Title="DSS Daysheets" Theme="defaultTheme"
    EnableEventValidation="false" %>

<%@ Register Assembly="skmParameters" Namespace="skmParameters" TagPrefix="skm" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <script type="text/javascript">
        function EligibilityQuestions(sender) {
            if (document.forms[0].ctl00_ContentPlaceHolder1_chkShowEligibilityQuestions.checked) {
                if (navigator.appName == "Microsoft Internet Explorer")
                    EligibilityQuestionsVB(sender);
                else
                    alert('Please note that Eligibility Questions only work with Internet Explorer');
            }
        }
    </script>
    <script type="text/vbscript" language="vbscript">
        Public Function EligibilityQuestionsVB(sender)
            If document.all("ctl00_ContentPlaceHolder1_chkShowEligibilityQuestions").checked Then
                intServiceCode = Right(document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlServiceCodes").Value, Len(document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlServiceCodes").Value)-2)
                Select Case intServiceCode    

                    Case 210, 211
                        document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "0"
                        document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "0"
                        document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                        Msgbox "Code 0, unless directed by Fiscal Manager to code 9 or R", vbOKOnly, "Eligibility Questions"
                           
                    Case 215
                        If Msgbox("Is the case risk level Moderate, High or Intensive?", vbYesNo, "Eligibility Questions") = vbYes Then
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "Z"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "Z"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                            Msgbox "Program Code 'Z' has been selected", vbOKOnly, "Eligibility Questions"
                        Else
                            If Msgbox("Is case level low risk?", vbYesNo, "Eligibility Questions") = vbYes Then
                                document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "R"
                                document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "R"
                                document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                                Msgbox "- Code 'R', for the 364 days of TANF eligibility, post CPS referral." + vbCrLf + "- Code 'X', after the 364 days of TANF eligibility" + vbCrLf + "- Code '9', if instructed by the Fiscal Manager", vbOKOnly, "Eligibility Questions"
                            End If
                        End If
                    
                    Case 9, 12, 19, 28, 109, 119, 128
                        If Msgbox("Is the child determined IV E eligible on the 5120 AND placed with a licensed provider (or with a relative in the process of becoming licensed)?", vbYesNo, "Eligibility Questions") = vbYes Then
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "Z"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "Z"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                            Msgbox "Program Code 'Z' has been selected" , vbOKOnly, "Eligibility Questions"
                        Else
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "P"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "P"
                            document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                            Msgbox "- Code 'P', if child is in DSS custody for less than 12 months" + vbCrLf + "- Code 'P', if child is in DSS custody for greater than 12 months and the plan is adoption or guardianship with an identified caretaker" + vbCrLf + "- Code 'R', if TANF eligible for the 364 days post referral date (and 'P' funds are no longer available)" + vbCrLf + "- Code 'X', if no other funding source is available" , vbOKOnly, "Eligibility Questions"                        
                        End If
                        
                    Case 330
                        If Msgbox("Is family TANF eligible?", vbYesNo, "Eligibility Questions") = vbYes Then
                                    document.all("ctl00$ContentPlaceHolder1$FormViewMain$ddlProgramCodes").Value = "R"
                                    document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value = "R"
                                    document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "0"
                                    Msgbox "- If family is TANF eligible, code 'R' for the 364 days post CPS crisis" + vbCrLf + "- If family is not TANF eligible, code 'X' unless instructed by Fiscal Manager to code '9'", vbOKOnly, "Eligibility Questions"
                        End If 
                                               
                End Select
            End If    
        End Function   
    </script>
    <script type="text/vbscript">
        Public Function CheckForOverride(sender)   
            If ( document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnProgramCode").Value <> "" ) Then
                document.all("ctl00$ContentPlaceHolder1$FormViewMain$hdnOverrideEQ").Value = "1"
            End If 
        End Function
    </script>
    <asp:SqlDataSource ID="dsGridViewGreen" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_DaysheetDetail_ForDateAndUser" SelectCommandType="StoredProcedure"
        DeleteCommand="spc_delete_Daysheet" DeleteCommandType="StoredProcedure" OnSelecting="dsGridViewGreen_Selecting">
        <SelectParameters>
            <asp:Parameter Name="DaysheetDate" Type="datetime" />
            <asp:Parameter Name="UserID" Type="String" />
            <asp:Parameter Name="DaysheetStyleID" Type="String" />
        </SelectParameters>
        <DeleteParameters>
            <asp:Parameter Name="DaysheetID" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsDetailsMain" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_DaysheetDetail_ForDaysheetID" SelectCommandType="StoredProcedure"
        UpdateCommand="spc_update_Daysheet" UpdateCommandType="StoredProcedure" InsertCommand="spc_insert_Daysheet"
        InsertCommandType="StoredProcedure" DeleteCommand="spc_delete_Daysheet" DeleteCommandType="StoredProcedure"
        OnInserting="dsDetailsMain_Inserting" OnUpdating="dsDetailsMain_Updating">
        <SelectParameters>
            <asp:ControlParameter ControlID="gvGreen" Name="DaysheetID" PropertyName="SelectedValue"
                Type="Int32" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="UserID" Type="String" />
            <asp:Parameter Name="DaysheetDate" Type="datetime" />
            <asp:Parameter Name="ClientID" Type="Int64" />
            <asp:Parameter Name="ServiceCodeWithClientIDFlag" Type="String" />
            <asp:Parameter Name="ProgramCodeID" Type="String" />
            <asp:Parameter Name="Minutes" Type="Int32" />
            <asp:Parameter Name="Comments" Type="String" />
            <asp:Parameter Name="DaysheetStyleID" Type="String" DefaultValue="Green" />
            <asp:Parameter Name="CaseName" Type="String" />
        </InsertParameters>
        <DeleteParameters>
            <asp:Parameter Name="DaysheetID" Type="Int32" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="DaysheetID" Type="Int32" />
            <asp:Parameter Name="UserID" Type="String" />
            <asp:Parameter Name="DaysheetDate" Type="datetime" />
            <asp:Parameter Name="ClientID" Type="Int64" />
            <asp:Parameter Name="ServiceCodeWithClientIDFlag" Type="String" />
            <asp:Parameter Name="ProgramCodeID" Type="String" />
            <asp:Parameter Name="Minutes" Type="Int32" />
            <asp:Parameter Name="Comments" Type="String" />
            <asp:Parameter Name="DaysheetStyleID" Type="String" />
            <asp:Parameter Name="CaseName" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>
    &nbsp;
    <asp:SqlDataSource ID="dsSISNumberList" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_ClientList_Active" SelectCommandType="StoredProcedure"
        DataSourceMode="DataReader"></asp:SqlDataSource>
    <asp:SqlDataSource ID="dsUserDetails" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_get_UserDetails_ForUserID" SelectCommandType="StoredProcedure"
        OnSelecting="dsUserDetails_Selecting" DataSourceMode="DataReader">
        <SelectParameters>
            <asp:Parameter Name="UserID" Type="string" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsServiceCodeList" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_ServiceCode" SelectCommandType="StoredProcedure" DataSourceMode="DataReader">
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsProgramCodeListWhite" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_ProgramCode" SelectCommandType="StoredProcedure" DataSourceMode="DataReader">
        <SelectParameters>
            <asp:Parameter Name="DaysheetStyleID" Type="String" DefaultValue="White" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="dsDaysheetStyle_ForUser" runat="server" ConnectionString="<%$ ConnectionStrings:DSSDaysheetConnectionString %>"
        SelectCommand="spc_dd_DaysheetStyle_ForUser" SelectCommandType="StoredProcedure"
        OnSelecting="dsDaysheetStyle_ForUser_Selecting" DataSourceMode="DataReader">
        <SelectParameters>
            <asp:Parameter Name="UserID" Type="string" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:ObjectDataSource ID="ods_ServiceCodes" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="get_all_ServiceCodes" TypeName="dsServiceCodeTableAdapters.ServiceCodesTableAdapter">
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="ods_ProgramCodes" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="get_all_ProgramCodes" TypeName="dsProgramCodeTableAdapters.ProgramCodesTableAdapter"
        OnSelecting="ods_ProgramCodes_Selecting">
        <SelectParameters>
            <asp:Parameter Name="DaysheetStyleID" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:FormView ID="FormView1" runat="server" DataSourceID="dsUserDetails">
        <ItemTemplate>
            <h1>
                <%= GetDaysheetDate().ToString("d") %>
                -
                <%# Eval("FullName") %></h1>
        </ItemTemplate>
    </asp:FormView>
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <strong>Daysheet Style:</strong>
    <asp:DropDownList ID="ddDaysheetStyle" runat="server" DataSourceID="dsDaysheetStyle_ForUser"
        DataTextField="DaysheetStyleID" DataValueField="DaysheetStyleID" AutoPostBack="True"
        OnSelectedIndexChanged="ddDaysheetStyle_SelectedIndexChanged" EnableViewState="true">
    </asp:DropDownList>
    <br />
    <br />
    <asp:Label ID="ErrorMessageLabel" runat="server" CssClass="errorMessage" Visible="False"></asp:Label>
    <br />
    <asp:Panel ID="panelEligibilityQuestions" runat="server">
        <asp:CheckBox ID="chkShowEligibilityQuestions" runat="server" Text="Show Eligibility Questions"
            OnCheckedChanged="UpdateEligibilitySession" AutoPostBack="true" />
    </asp:Panel>
    <asp:Label ID="lblLocked" CssClass="errorMessage" runat="server" Text="* Record locked for editing *"
        Visible="false"></asp:Label>
    <asp:FormView runat="server" ID="FormViewMain" DataSourceID="dsDetailsMain" DefaultMode="insert"
        DataKeyNames="DaysheetID" OnItemInserted="FormViewMain_ItemInserted" OnItemUpdated="FormViewMain_ItemUpdated"
        OnDataBound="FormViewMain_DataBound" OnItemInserting="FormViewMain_ItemInserting"
        OnItemUpdating="FormViewMain_ItemUpdating">
        <HeaderTemplate>
            <table cellspacing="0" cellpadding="2" border="0" id="tblDetail" class="detailsView">
        </HeaderTemplate>
        <ItemTemplate>
        </ItemTemplate>
        <InsertItemTemplate>
            <asp:Panel ID="pnlSISNumber" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        SIS #
                    </td>
                    <td>
                        <asp:DropDownList ID="ddSISNumber" runat="server" DataSourceID="dsSISNumberList"
                            DataTextField="FullName" DataValueField="ClientID" SelectedValue='<%# Bind("ClientID") %>'>
                        </asp:DropDownList>
                        <ajaxToolkit:ListSearchExtender ID="ListSearchExtender1" runat="server" TargetControlID="ddSISNumber"
                            PromptCssClass="ListSearchExtenderPrompt" PromptPosition="top" PromptText="">
                        </ajaxToolkit:ListSearchExtender>
                        <asp:RequiredFieldValidator ID="vSISNumber" runat="server" ControlToValidate="ddSISNumber"
                            ErrorMessage="<br />SIS # is required for this Service Code/Program Code combination"
                            InitialValue="0" Display="Dynamic" Enabled="false" />
                    </td>
                </tr>
            </asp:Panel>
            <asp:Panel ID="pnlCaseName" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        Case Name
                    </td>
                    <td>
                        <asp:TextBox ID="txtCaseName" runat="server" Text='<%# Bind("CaseName") %>' Width="250"></asp:TextBox>
                    </td>
                </tr>
            </asp:Panel>
            <asp:Panel ID="pnlServiceCode" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        Svc Code
                    </td>
                    <td>
                        <asp:Label ID="lblServiceCode" runat="server" Text='<%# Bind("ServiceCodeWithClientIDFlag") %>'
                            Visible="false"></asp:Label>
                        <asp:DropDownList ID="ddlServiceCodes" runat="server" CssClass="max-height: 100px;"
                            DataSourceID="ods_ServiceCodes" DataTextField="ServiceCodeDescription" DataValueField="ServiceCodeWithClientIDFlag">
                            <asp:ListItem></asp:ListItem>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="vServiceCode" runat="server" ControlToValidate="ddlServiceCodes"
                            ErrorMessage="Please select a Service Code from the list" InitialValue="0-" Display="Dynamic"
                            Enabled="false" />
                        <ajaxToolkit:CascadingDropDown ID="CascadingDropDown1" runat="server" Category="Service Codes"
                            LoadingText="Please wait..." ParentControlID="ddlServiceCodes" PromptText="- Select -"
                            TargetControlID="ddlProgramCodes" ServicePath="ProgramAndServiceCodes.asmx" ServiceMethod="GetProgramCodesByServiceCode" />
                    </td>
                </tr>
            </asp:Panel>
            <tr class="detailsViewRow">
                <td>
                    Prg Code
                </td>
                <td>
                    <asp:DropDownList ID="ddlProgramCodes" runat="server" CssClass="max-height: 100px;">
                        <asp:ListItem></asp:ListItem>
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddProgramCodesWhite" runat="server" CssClass="max-height: 100px;"
                        DataSourceID="dsProgramCodeListWhite" DataTextField="ProgramCodeDescription"
                        DataValueField="ProgramCodeID" Visible="false">
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="vProgramCode" runat="server" ControlToValidate="ddlProgramCodes"
                        ErrorMessage="<br />Please select a Program Code from the list" InitialValue=""
                        Display="Dynamic" EnableClientScript="false" />
                    <asp:HiddenField ID="hdnProgramCode" runat="server" Value="" Visible="true" />
                    <asp:HiddenField ID="hdnOverrideEQ" runat="server" Value="0" Visible="true" />
                    <asp:Label ID="lblProgramCode" runat="server" Text='<%# Bind("ProgramCodeID") %>'
                        Visible="false" />
                </td>
            </tr>
            <tr class="detailsViewRow">
                <td>
                    Minutes
                </td>
                <td>
                    <asp:TextBox ID="txtMinutes" runat="server" Width="40px" Text='<%# Bind("Minutes") %>'></asp:TextBox>
                    <asp:RangeValidator ID="rvMinutes" runat="server" ErrorMessage="Minutes must be numeric."
                        Type="integer" MinimumValue="0" MaximumValue="999999" ControlToValidate="txtMinutes"
                        Display="Dynamic" EnableClientScript="false">
                    </asp:RangeValidator>
                    <asp:RequiredFieldValidator ID="vMinutes" runat="server" ControlToValidate="txtMinutes"
                        ErrorMessage="Please enter a value for Minutes." Display="Dynamic" EnableClientScript="false" />
                </td>
            </tr>
            <tr class="detailsViewRow">
                <td>
                    Comments
                </td>
                <td>
                    <asp:TextBox ID="txtComments" runat="server" Text='<%# Bind("Comments") %>' Width="450px"></asp:TextBox>
                </td>
            </tr>
        </InsertItemTemplate>
        <EditItemTemplate>
            <asp:Panel ID="pnlSISNumber" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        SIS #
                    </td>
                    <td>
                        <asp:DropDownList ID="ddSISNumber" runat="server" DataSourceID="dsSISNumberList"
                            DataTextField="FullName" DataValueField="ClientID" SelectedValue='<%# Bind("ClientID") %>'>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="vSISNumber" runat="server" ControlToValidate="ddSISNumber"
                            ErrorMessage="<br />SIS # is required for this Service Code/Program Code combination"
                            InitialValue="0" Display="Dynamic" Enabled="false" />
                    </td>
                </tr>
            </asp:Panel>
            <asp:Panel ID="pnlCaseName" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        Case Name
                    </td>
                    <td>
                        <asp:TextBox ID="txtCaseName" runat="server" Text='<%# Bind("CaseName") %>'></asp:TextBox>
                    </td>
                </tr>
            </asp:Panel>
            <asp:Panel ID="pnlServiceCode" runat="server" Visible="True">
                <tr class="detailsViewRow">
                    <td>
                        Svc Code
                    </td>
                    <td>
                        <asp:Label ID="lblServiceCode" runat="server" Text='<%# Bind("ServiceCodeWithClientIDFlag") %>'
                            Visible="false"></asp:Label>
                        <asp:DropDownList ID="ddlServiceCodes" runat="server" CssClass="max-height: 100px;"
                            DataSourceID="ods_ServiceCodes" DataTextField="ServiceCodeDescription" DataValueField="ServiceCodeWithClientIDFlag"
                            OnSelectedIndexChanged="ddlServiceCodes_SelectedIndexChanged">
                            <asp:ListItem></asp:ListItem>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="vServiceCode" runat="server" ControlToValidate="ddlServiceCodes"
                            ErrorMessage="Please select a Service Code from the list" InitialValue="0-" Display="Dynamic"
                            Enabled="false" />
                        <ajaxToolkit:CascadingDropDown ID="CascadingDropDown1" runat="server" Category="Service Codes"
                            LoadingText="Please wait..." ParentControlID="ddlServiceCodes" PromptText="- Select -"
                            TargetControlID="ddlProgramCodes" ServicePath="ProgramAndServiceCodes.asmx" ServiceMethod="GetProgramCodesByServiceCode" />
                    </td>
                </tr>
            </asp:Panel>
            <tr class="detailsViewRow">
                <td>
                    Prg Code
                </td>
                <td>
                    <asp:DropDownList ID="ddlProgramCodes" runat="server" CssClass="max-height: 100px;">
                        <asp:ListItem></asp:ListItem>
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddProgramCodesWhite" runat="server" CssClass="max-height: 100px;"
                        DataSourceID="dsProgramCodeListWhite" DataTextField="ProgramCodeDescription"
                        DataValueField="ProgramCodeID" Visible="false">
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="vProgramCode" runat="server" ControlToValidate="ddlProgramCodes"
                        ErrorMessage="<br />Please select a Program Code from the list" InitialValue=""
                        Display="Dynamic" EnableClientScript="false" />
                    <asp:HiddenField ID="hdnProgramCode" runat="server" Value="" Visible="true" />
                    <asp:HiddenField ID="hdnOverrideEQ" runat="server" Value="0" Visible="true" />
                    <asp:Label ID="lblProgramCode" runat="server" Text='<%# Bind("ProgramCodeID") %>'
                        Visible="false" />
                </td>
            </tr>
            <tr class="detailsViewRow">
                <td>
                    Minutes
                </td>
                <td>
                    <asp:TextBox ID="txtMinutes" runat="server" Width="40px" Text='<%# Bind("Minutes") %>'></asp:TextBox>
                    <asp:RangeValidator ID="rvMinutes" runat="server" ErrorMessage="Minutes must be numeric."
                        Type="integer" MinimumValue="0" MaximumValue="999999" ControlToValidate="txtMinutes"
                        Display="Dynamic" EnableClientScript="false">
                    </asp:RangeValidator>
                    <asp:RequiredFieldValidator ID="vMinutes" runat="server" ControlToValidate="txtMinutes"
                        ErrorMessage="Please enter a value for Minutes." Display="Dynamic" EnableClientScript="false" />
                </td>
            </tr>
            <tr class="detailsViewRow">
                <td>
                    Comments
                </td>
                <td>
                    <asp:TextBox ID="txtComments" runat="server" Text='<%# Bind("Comments") %>' Width="450px"></asp:TextBox>
                </td>
            </tr>
        </EditItemTemplate>
        <FooterTemplate>
            <tr>
                <td colspan="2">
                    <asp:LinkButton ID="FormViewUpdateButton" Text="Save" CommandName="Update" runat="server"></asp:LinkButton>
                    <asp:LinkButton ID="FormViewInsertButton" Text="Save" CommandName="Insert" runat="server"></asp:LinkButton>
                    &nbsp;&nbsp;
                    <asp:LinkButton ID="FormViewCancelButton" Text="Cancel" CommandName="Cancel" runat="server"></asp:LinkButton>
                </td>
            </tr>
            </table>
        </FooterTemplate>
    </asp:FormView>
    <br />
    <br />
    <asp:GridView ID="gvGreen" runat="server" AutoGenerateColumns="False" DataKeyNames="DaysheetID"
        DataSourceID="dsGridViewGreen" AllowSorting="True" BackColor="Beige" ShowFooter="True"
        OnSelectedIndexChanged="GridView1_SelectedIndexChanged" OnRowDataBound="GridView1_RowDataBound"
        OnSorted="GridView1_Sorted" OnDataBinding="GridView1_DataBinding" EnableViewState="False">
        <Columns>
            <asp:TemplateField ShowHeader="False">
                <ItemTemplate>
                    <asp:ImageButton ID="imgDelete" runat="server" CausesValidation="False" CommandName="Delete"
                        ImageUrl="~/images/delete.png" AlternateText="Delete" />
                    <ajaxToolkit:ConfirmButtonExtender ID="cbe" runat="server" TargetControlID="imgDelete"
                        ConfirmText="Are you sure you want to delete this Daysheet record?" />
                    <asp:ImageButton ID="imgEdit" runat="server" CausesValidation="False" CommandName="Select"
                        ImageUrl="~/images/edit.png" AlternateText="Edit" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DaysheetID" HeaderText="DaysheetID" InsertVisible="False"
                ReadOnly="True" SortExpression="DaysheetID" Visible="False" />
            <asp:BoundField DataField="UserID" HeaderText="UserID" SortExpression="UserID" Visible="False" />
            <asp:BoundField DataField="ClientFullName" HeaderText="SIS # (Client)" SortExpression="ClientFullName" />
            <asp:BoundField DataField="CaseName" HeaderText="Case Name" SortExpression="CaseName"
                Visible="False" />
            <asp:BoundField DataField="ServiceCodeID" HeaderText="Svc Code" SortExpression="ServiceCodeID" />
            <asp:BoundField DataField="ProgramCodeID" HeaderText="Prg Code" SortExpression="ProgramCodeID" />
            <asp:BoundField DataField="Minutes" HeaderText="Minutes" SortExpression="Minutes"
                HtmlEncode="False" DataFormatString="{0:N0}">
                <ItemStyle CssClass="padNumericCell" HorizontalAlign="Right" />
                <FooterStyle CssClass="padNumericCell" HorizontalAlign="Right" />
            </asp:BoundField>
            <asp:TemplateField HeaderText="Comments" SortExpression="Comments">
                <EditItemTemplate>
                    <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Comments") %>'></asp:TextBox>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label1" runat="server" Text='<%# Bind("Comments") %>'></asp:Label>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:LinkButton ID="RemainderToGAButton" Text="Remainder to GA" Font-Bold="false"
                        CommandName="RemainderToGA" runat="server" OnClick="RemainderToGA" CausesValidation="false"></asp:LinkButton>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DaysheetStyleID" Visible="False" />
            <asp:BoundField DataField="ServiceCodeWithClientIDFlag" Visible="False" />
        </Columns>
        <FooterStyle Font-Bold="True" />
    </asp:GridView>
    <br />
    <div style="text-align: left">
        <asp:HyperLink ID="hypNextPage" runat="server" Text="Next Day" Visible="true" /></div>
</asp:Content>
