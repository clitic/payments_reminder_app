/// All user-facing strings for the Payment Reminder App
/// Centralized string management for easy localization and maintenance
library;

class AppStrings {
  AppStrings._();

  // =============================================================================
  // APP GENERAL
  // =============================================================================

  static const String appName = 'Payment Reminder';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String all = 'All';
  static const String none = 'None';

  // =============================================================================
  // AUTHENTICATION
  // =============================================================================

  static const String login = 'Login';
  static const String register = 'Register';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String continueAsGuest = 'Continue as Guest';
  static const String guestMode = 'Guest Mode';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String welcomeBack = 'Welcome Back!';
  static const String createYourAccount = 'Create your account';
  static const String loginToContinue = 'Login to continue';
  static const String guestModeInfo =
      'You can use the app without an account, but your data will not be synced to the cloud.';
  static const String convertToFullAccount = 'Convert to Full Account';
  static const String signInToContinue = 'Sign in to continue';
  static const String accountCreated = 'Account created successfully!';
  static const String paymentUpdated = 'Payment updated successfully';
  static const String paymentAdded = 'Payment added successfully';

  // =============================================================================
  // VALIDATION MESSAGES
  // =============================================================================

  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String titleRequired = 'Title is required';
  static const String amountRequired = 'Amount is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String dueDateRequired = 'Due date is required';
  static const String categoryRequired = 'Please select a category';

  // =============================================================================
  // ERROR MESSAGES
  // =============================================================================

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorEmailAlreadyInUse = 'This email is already registered';
  static const String errorWeakPassword = 'Password is too weak';
  static const String errorUserNotFound = 'No account found with this email';
  static const String errorTooManyRequests = 'Too many attempts. Please try again later.';
  static const String errorOperationNotAllowed = 'This operation is not allowed';
  static const String errorDatabaseError = 'Database error occurred';
  static const String errorSyncFailed = 'Failed to sync data. Will retry later.';
  static const String errorBiometricNotAvailable = 'Biometric authentication not available';
  static const String errorBiometricFailed = 'Biometric authentication failed';

  // =============================================================================
  // SUCCESS MESSAGES
  // =============================================================================

  static const String successPaymentAdded = 'Payment added successfully';
  static const String successPaymentUpdated = 'Payment updated successfully';
  static const String successPaymentDeleted = 'Payment deleted successfully';
  static const String successPaymentMarkedPaid = 'Payment marked as paid';
  static const String successSyncComplete = 'Data synced successfully';
  static const String successLogout = 'Logged out successfully';
  static const String successAccountCreated = 'Account created successfully';

  // =============================================================================
  // PAYMENT RELATED
  // =============================================================================

  static const String payments = 'Payments';
  static const String payment = 'Payment';
  static const String addPayment = 'Add Payment';
  static const String editPayment = 'Edit Payment';
  static const String deletePayment = 'Delete Payment';
  static const String paymentTitle = 'Payment Title';
  static const String amount = 'Amount';
  static const String dueDate = 'Due Date';
  static const String category = 'Category';
  static const String frequency = 'Frequency';
  static const String notes = 'Notes (Optional)';
  static const String reminderTiming = 'Reminder Timing';
  static const String markAsPaid = 'Mark as Paid';
  static const String markAsUnpaid = 'Mark as Unpaid';
  static const String upcoming = 'Upcoming';
  static const String paid = 'Paid';
  static const String overdue = 'Overdue';
  static const String noPayments = 'No payments found';
  static const String noUpcomingPayments = 'No upcoming payments';
  static const String noPaidPayments = 'No paid payments yet';
  static const String noOverduePayments = 'No overdue payments';
  static const String paymentHistory = 'Payment History';
  static const String viewAll = 'View All';
  static const String totalDue = 'Total Due';
  static const String totalPaid = 'Total Paid';
  static const String deletePaymentConfirm = 'Are you sure you want to delete this payment?';
  static const String paymentDetails = 'Payment Details';

  // =============================================================================
  // DASHBOARD
  // =============================================================================

  static const String dashboard = 'Dashboard';
  static const String home = 'Home';
  static const String calendar = 'Calendar';
  static const String history = 'History';
  static const String settings = 'Settings';
  static const String summary = 'Summary';
  static const String quickActions = 'Quick Actions';
  static const String recentPayments = 'Recent Payments';
  static const String thisMonth = 'This Month';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';

  // =============================================================================
  // CALENDAR
  // =============================================================================

  static const String calendarView = 'Calendar View';
  static const String noPaymentsOnDate = 'No payments on this date';
  static const String selectDate = 'Select Date';

  // =============================================================================
  // SETTINGS
  // =============================================================================

  static const String account = 'Account';
  static const String security = 'Security';
  static const String notifications = 'Notifications';
  static const String appearance = 'Appearance';
  static const String sync = 'Sync';
  static const String about = 'About';
  static const String biometricLock = 'Biometric Lock';
  static const String biometricLockDescription =
      'Use fingerprint or face recognition to unlock the app';
  static const String enableNotifications = 'Enable Notifications';
  static const String notificationSettings = 'Notification Settings';
  static const String darkMode = 'Dark Mode';
  static const String theme = 'Theme';
  static const String lightTheme = 'Light';
  static const String darkTheme = 'Dark';
  static const String systemTheme = 'System';
  static const String syncNow = 'Sync Now';
  static const String lastSynced = 'Last synced';
  static const String neverSynced = 'Never synced';
  static const String syncInProgress = 'Syncing...';
  static const String clearAllData = 'Clear All Data';
  static const String clearDataConfirm =
      'This will delete all your local data. Are you sure?';
  static const String version = 'Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String contactSupport = 'Contact Support';
  static const String rateApp = 'Rate App';

  // =============================================================================
  // NOTIFICATIONS
  // =============================================================================

  static const String reminderTitle = 'Payment Reminder';
  static const String reminderDueToday = 'is due today';
  static const String reminderDueTomorrow = 'is due tomorrow';
  static const String reminderDueSoon = 'is due soon';
  static const String reminderOverdue = 'is overdue';
  static const String snooze = 'Snooze';
  static const String snooze1Hour = 'Snooze 1 hour';
  static const String snooze1Day = 'Snooze 1 day';

  // =============================================================================
  // BIOMETRIC
  // =============================================================================

  static const String authenticateToAccess = 'Authenticate to access Payment Reminder';
  static const String biometricPromptTitle = 'Biometric Authentication';
  static const String biometricPromptSubtitle = 'Verify your identity';
  static const String usePassword = 'Use Password';

  // =============================================================================
  // SORT OPTIONS
  // =============================================================================

  static const String sortByDueDate = 'Due Date';
  static const String sortByAmount = 'Amount';
  static const String sortByTitle = 'Title';
  static const String sortAscending = 'Ascending';
  static const String sortDescending = 'Descending';

  // =============================================================================
  // FILTER OPTIONS
  // =============================================================================

  static const String filterByCategory = 'Category';
  static const String filterByStatus = 'Status';
  static const String clearFilters = 'Clear Filters';
  static const String applyFilters = 'Apply Filters';
}
