# Advanced iOS AT3: Project 2 

## 'Hikes Near Me' App

## Github Repository Link: https://github.com/byro23/Advanced-iOS-AT3

## Instructions

### Package Dependences

All package dependencies should automatically install upon after cloning the repository.
If the dependencies do not install, please use the Swift Package Manager to install the following:

- Google Places SDK For iOS Swift ``` https://github.com/googlemaps/ios-places-sdk ```
- Firebase iOS SDK ``` https://github.com/firebase/firebase-ios-sdk ``` (With FirebaseFirestore & FirebaseAuth added to target)

### API Key
For safety, the Google Places API key is not included in the project's code and will need to be added manually. 

The **api key** will be provided through the submission comments on **Canvas**.

***It is crucial the API key is added, otherwise the map will not show the hike annotations***.

To add the API key to the project:

1. Copy the API key from the Canvas comments.
2. Inside Xcode go to the top menubar and select `Product` -> `Scheme` -> `Edit Scheme`
3. Select `Run` along the left handside
4. Select `environment variables`
5. Paste the API key as the value for `PLACES_API_KEY`

#### API Key Location

![image](https://github.com/user-attachments/assets/2ff7547b-2d05-44ae-8afe-e7ee20900157)


## Description

The Hike Near Me app allows users to discover hikes near to their location or through a search of a specific location using the map provided by **Mapkit**.
These hikes are annotated on the map where users can tap on the hike to discover more information. As the user navigates the map the annotations are generated for the currently view region. The hike information is retrieved through the **Google Places API**. After tapping the hike, users can then press the heart icon to add it to their favourites. These favourites are locally stored on the device through **Core Data**. However, users have the option to store a cloud backup (through **Firebase**) of their favourites, allowing them to restore their favourites if their local data is lost. To allow multiple users of the phone to access the cloud favourites functionality, the user will have to register and login to associate their cloud backup with their account.

From the favourites menu, the user is presented their favourites showing the hike name and address. All favourites are order from most recent in descending order. In this menu, the users is able to delete individual favourites (through swiping), clear all favourites, or initiate a cloud backup. Furthermore, the user has the option to tap the a favourite, providing the option to go to the location on the map or view the favourite's additional details.

The last view of the app is the SettingsView, where the user can switch between light and dark modes or default to the system setting. Lastly, the user can restore their favourites by tapping the 'restore favourites from cloud button'.

## Primary Views

- MapView
  - Map implemented through mapkit
  - Annotations generated through information fetched through Google places API
  - Location search autocomplete through Mapkit
  - Annotations appear as user navigates to certain regions
  - Screenshot:
  - ![image](https://github.com/user-attachments/assets/afec066f-3585-4e43-ad37-453b0f6cd751)

- HikeDetailsView
  - Information is retrieved from 'Hike' object based on information fetched from Google Places API
  - Favourite button instantly adds a 'FavouriteHike' to Core Data.
  - Screenshot:
  - ![Simulator Screenshot - iPhone 16 Pro - 2024-10-13 at 10 22 33](https://github.com/user-attachments/assets/4051c239-91ed-496a-b07a-992eaa2fd109)
 
- FavouritesView
  - Presents a list of the 'FavouriteHikes' stored in Core Data
  - Swipe gestures can be utilised to remove individual favourites
  - Clear all button will delete all favourites from core data
  - Cloud backup button which will upload a snapshot of the current favourites to cloud storage
  - Screenshots:
  - ![image](https://github.com/user-attachments/assets/068cb87e-762e-4fa3-9724-e0ada675322b)
  - ![Simulator Screenshot - iPhone 16 Pro - 2024-10-13 at 10 18 30](https://github.com/user-attachments/assets/6b790839-d77c-40de-a89c-59d5dce8f9e0)

- SettingsView
  - A toggle which allows the user to switch between light, dark, or system themes
  - A view backup button which shows a snapshot of the favourites backup
  - A restore cloud backup button which restores the backup to local storage,
  - A delete favourites from cloud button which allows the user to remove their cloud backup
  - A logout button, taking the user back to the LandingView
  - Screenshot:
  - ![Simulator Screenshot - iPhone 16 Pro - 2024-10-13 at 10 18 19](https://github.com/user-attachments/assets/f0221f64-f02e-4ddb-ba21-9018f00a775d)
 
- LandingView
  - Provides user login, authentication provided through Google FirebaseAuth
  - Screenshot:
  - ![Simulator Screenshot - iPhone 16 Pro - 2024-10-13 at 10 26 07](https://github.com/user-attachments/assets/a693cdea-ddbb-45fc-9a98-93dbdd3523ae)
 
- RegistrationView
  - Allows users to register to the system
  - Account creation and detail storage achieved through Google FirebaseAuth/Firebase Firestore
  - Screenshot:
  - ![Simulator Screenshot - iPhone 16 Pro - 2024-10-13 at 10 17 34](https://github.com/user-attachments/assets/646b662c-be39-49c9-8e6d-f40c1cf0294d)
 
## Error Handling Strategy 

The primary techniques employed for error handling are:
- do-catch blocks for operations that can throw exceptions. This is mainly involved with API calls and remote database access.
- Console logs providing a localised description of the error to improve troubleshooting efficiency. 
- Errors that impact the user are communicated through popups or status messages.
- Default behaviours for unexpected inputs or failures to prevent crashes.

## **Note**

- The inclusion of the Google Place sdk unfortunately breaks previews. Therefore, the simulator is the only way to view the app screens.
- The API requests have been set to debounce with a 1 second delay. This reduces responsiveness in the loading of annotations but ensures I don't use up my free API credits.




