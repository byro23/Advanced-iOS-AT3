# Advanced iOS AT3: Project 2 

## 'Hikes Near Me' App

## Package Dependences

All package dependencies should automatically install upon after cloning the repository.
If the dependencies do not install, please use the Swift Package Manager to install the following:

- Google Places SDK For iOS Swift ``` https://github.com/googlemaps/ios-places-sdk ```
- Firebase iOS SDK ``` https://github.com/firebase/firebase-ios-sdk ``` (With FirebaseFirestore added to target)

## Description
The Hike Near Me app allows users to discover hikes near to their location or through a search of a specific location using the map provided by **Mapkit**.
These hikes are annotated on the map where users can tap on the hike to discover more information. The hike information is retrieved through the **Google Places API**.
After tapping the hike, users can then press the heart icon to add it to their favourites. These favourites are locally stored on the device through **Core Data**

