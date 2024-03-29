# <img width="40" alt="eco-playstore" src="https://user-images.githubusercontent.com/42720743/124920860-1315a080-dff8-11eb-9d03-05d399f4ebf4.png"> Pensum

[Privacy Policy](privacy.md)\
[Support](support.md)

[<img src="https://user-images.githubusercontent.com/42720743/124749402-78985d00-df24-11eb-98ed-b5aa270957ab.png" alt="drawing" width="200"/>](https://apps.apple.com/us/app/leaf-reuse-socially/id1568882763)
[<img src="https://user-images.githubusercontent.com/42720743/124749936-26a40700-df25-11eb-8eae-0677b40da416.png" alt="drawing" width="200"/>](https://play.google.com/store/apps/details?id=art.rootly.leaf)

A flutter project for buying and selling books, mainly campus curriculum socially. It uses a **MVVM** architecture achieved with the *provider* packages and *firebase* as the backend. All lists iclude **paging** with *ScrollNotification* and lazy loading with use of *ListView.builder* method. The code is now migrated to *Sound Null Safety*. Currently the project includes the following features:
* Authentication
* Chat (incl. images, GIF and location)
* Profile
* Filtering
* Search
* Localization
* Notifications
* Presence system

### Screenshots

<img src="screenshots/1.png" alt="drawing" width="200"/> <img src="screenshots/2.png" alt="drawing" width="200"/> <img src="screenshots/3.png" alt="drawing" width="200"/> <img src="screenshots/5.png" alt="drawing" width="200"/>

### Usage

To install the application locally you first need to clone this repository, then run

	flutter pub get

to install the dependencies, the project still need to be connected with the backend i.e. *firebase*. This can be done by installing the necessary files services files for android and ios from firebase.google.com. Ideally run the project from VSCode or connect to a device and run:

	flutter run
