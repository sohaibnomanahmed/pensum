# Leaf

[Privacy Policy](privacy.md)
[Support](support.md)

A flutter project for buying and selling books, mainly campus curriculum socially. It uses a **MVVM** architecture achieved with the *provider* packages and *firebase* as the backend. Currently the project includes the following features:
* Authentication
* Chat (incl. images and location)
* Profile
* Deals filtering
* Book search
* Notifications
* Presence system

### Example Screenshots

<img src="https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0316.PNG?token=AKF53Z66KCKZIJZOH7RR4BLAW7B44" alt="drawing" width="200"/>

![1](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0316.PNG?token=AKF53Z66KCKZIJZOH7RR4BLAW7B44 | width=200) ![2](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0322.PNG?token=AKF53Z7PGCDPQ7O2PBHTFADAW7CC2 "book list") ![3](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0319.PNG?token=AKF53Z27746E5YHA4TBFREDAW7B7S "deals") ![4](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0325.PNG?token=AKF53ZYTBTR7UMGXS7HABX3AW7CMS "location message") ![5](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0323.PNG?token=AKF53Z5Q7WMS7RK3NLQT5NLAW7CJU "notification") ![6](https://raw.githubusercontent.com/sohaibnoman/leaf/main/screenshots/IMG_0321.PNG?token=AKF53Z4XGN2QMDZ7G7RU5A3AW7CGC "image message")

### Usage

To install the application locally you first need to clone this repository, then run

	flutter pub get

to install the dependencies, the project still need to be connected with the backend i.e. *firebase*. This can be done by installing the necessary files services files for android and ios from firebase.google.com. Ideally run the project from VSCode or connect to a device and run:

	flutter run
