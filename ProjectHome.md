Welcome to the Survey Shark project.

_Don't just fish for the answers you need, hunt them down_

This is intended to be a simple Force.com Sites example application, built with developers in mind, it demonstrates how to construct a survey application using Force.com and Sites.  The techniques shown here should be generally useful for many applications where the requirement is to gather data, but you do not need the higher level of security provided by fully authenticated users on a Force.com Customer Portal.


The Application should be installed in a Force.com Sites enabled edition of Salesforce.com.   The application is provided in two distributions, a source code project (see **Source** tab) and a **Get It Now** package located in the **Links:** area of this project.

This is an un-managed package so that you can make any required changes to the look and feel of the resulting survey wizard.

Please use the **Issues** tab to record any problems that you encounter.

---


## Included in this application ##
A **Survey** object contains one or more <b>Question</b> objects and forms the basis for the survey content.

The **Invitation** object joins a contact record to a survey. This is the object that forms the basis for inviting a contact to fill in the data for a particular survey, it is used to build the email which will be sent to the contact.

Data that is gathered from the contact is stored in **Response** objects when the survey is completed

There are links or buttons for often performed operations.
<ul>
<blockquote><li>A button to mass edit questions</li>
<li>a link to close a survey and delete outstanding invitations<br>
, called close survey</li>
<li>a link on the invitation to preview / take the survey, this<br>
can be included in email templates</li></blockquote>

<blockquote><li>a link to mass create invitations</li>
<li>a link to mass send invitations</li>
</ul></blockquote>


In addition to the objects, pages and code, the package includes two simple email templates that will allow you to customize your own email
invitaion templates.  These templates, and any template in the survey folder are available to be used by the link that allows you to send mass emails to
the contacts in the invite list.


## Typical Usage ##
<ul>

<li>Build a Survey record that contains a description and a landing page ( thank you page), specify the number of questions per page</li>
<li>Click the button on the Survey detail page to Edit Questions, add a few questions to your survey</li>
<li>Click the button to create invitations that will be used to define who will be requested to take the survey</li>
<li>Click the link to Send Invitations, this will allow you to specify the template and which invitations should be sent</li>
<li>Build your own custom reports to summarize the responses as they roll in</li>
</ul>



## Setup Steps ##
After install this package you must configure your site so that the survey can be completed by contacts that are invited to provide information to be recorded in your database.  The setup steps are described in the About Survey Shark tab after you have installed the application.
