# ASHA-Setu Features

## OTP Authentication
**Screen:** `login_screen.dart`, `otp_screen.dart`
**Description:** A secure, password-less authentication system allowing ASHA workers to access the app swiftly using their phone number. Verified via SMS texts, this method ensures an easy login experience on the field.
**Key Functionality:**
- Phone number input field pre-filled with the +91 country code.
- 6-digit OTP delivery powered by AWS SNS.
- Quick OTP verification with a built-in 5-minute expiry window.
- Secure JWT token generation upon successful validation.
- Automatic redirection to the main dashboard after login.

## Dashboard
**Screen:** `dashboard_screen.dart`
**Description:** The central hub of the app, providing a personalized overview of the worker's day. It highlights essential statistics and pressing tasks to help the worker prioritize activities.
**Key Functionality:**
- A warm welcome greeting displaying the active worker's name.
- Daily statistics cards showcasing patients visited and pending tasks.
- Priority alerts warning the worker about overdue follow-ups or visits.
- Quick action pills for fast navigation between core app functions.
- A manual sync button for quick data refresh from the cloud.
- Easy and secure logout functionality.

## Patient Management
**Screen:** `patients_screen.dart`, `add_patient_screen.dart`
**Description:** A complete system for managing the health records of citizens under the worker's care, categorized efficiently by their health status.
**Key Functionality:**
- View all assigned patients organized in a scrolling list format.
- Quickly filter patients by specific healthcare categories (ANC, PNC, Infant, General).
- Add new patient records including detailed metadata (name, age, gender, category).
- Seamlessly assign individual patients to registered households.
- Track Expected Date of Delivery (EDD) specifically for pregnant (ANC) patients.

## Visit Tracking
**Screen:** `visit_form_screen.dart`
**Description:** Facilitates the recording of health vitals and clinical observations during a house visit, securely storing the data for district officers to review.
**Key Functionality:**
- Easy logging of house visits, specifying the date and outcome.
- Comprehensive vital recording including blood pressure, weight, temperature, and blood sugar.
- Ability to append detailed free-text notes for unique observations from each visit.
- Automatic incrementation and tracking of the worker's total visit statistics.

## Calendar
**Screen:** `calendar_screen.dart`
**Description:** A visual scheduling tool helping workers track their historical activity and upcoming appointments or health drives.
**Key Functionality:**
- A comprehensive monthly calendar view for broad planning.
- Ability to select specific dates and view the agenda of scheduled patient visits.
- Clear visual indicators highlighting busy and free days at a glance.

## Inventory Management
**Screen:** `inventory_screen.dart`
**Description:** An administrative tool enabling the worker to monitor and track the consumption of their field medical supplies and testing kits.
**Key Functionality:**
- An alphabetically sorted view of all current medical supplies (e.g., ORS packets, specific medicines, test kits).
- Ability to add new inventory types by specifying the name, base quantity, and unit of measurement.
- Real-time quantity updating when supplies are consumed during treatments.
- Easy deletion function to remove items that are discontinued or no longer tracked.

## Learning Modules
**Screen:** `learning_screen.dart`
**Description:** An educational hub promoting continuous learning among ASHA workers, providing them with essential up-to-date health procedures and guides.
**Key Functionality:**
- Direct access to browse available training and informational modules.
- Advanced progress tracking categorized by status (Not Started, In Progress, Completed).
- Detailed module overviews indicating reading/watching duration and description content.
- External links to rich media content such as tutorial videos and medical articles.

## Messaging
**Screen:** `messenger_screen.dart`
**Description:** A built-in chat interface replicating the ease of modern messaging applications, offering direct lines of communication between workers and their supervisors.
**Key Functionality:**
- A fluid, real-time chat interface connected with assigned district medical officers.
- Ability to seamlessly send and receive text messages within the platform.
- Message read status tracking combined with distinct chat bubble styling for clarity.
- Support for critical worker-to-admin communications to relay important local directives.

## Emergency Contacts
**Screen:** `emergency_screen.dart`
**Description:** A critical life-saving feature providing one-tap access to local emergency services for fast intervention during field crises.
**Key Functionality:**
- A directory of quick-dial emergency numbers.
- Logical categorization matching various contact types (e.g., Hospital, Ambulance, Maternity Helpline).
- Direct integration with the phone dialer via one-tap calling functionality.

## Help & Support
**Screen:** `help_support_screen.dart`
**Description:** Provides technical support and general guidance for navigating the digital platform, minimizing operational friction for the workers.
**Key Functionality:**
- A comprehensive list of Frequently Asked Questions related to app operation.
- Direct support contact information for resolving technical glitches or login issues.
- A glossary of helpful articles and step-by-step guides for everyday app usage.

## Worker Profile
**Screen:** `profile_screen.dart`
**Description:** A dedicated space for the worker to review their own professional metadata, performance statistics, and personal information.
**Key Functionality:**
- Read-only dashboard of core professional details including the worker's name, employee ID, and assigned village or ward.
- The ability to edit profile information safely and accurately.
- Options to upload, update, and display a professional profile photograph.
- A localized view of individual performance statistics, such as total career visits and currently assigned numbers of patients.
