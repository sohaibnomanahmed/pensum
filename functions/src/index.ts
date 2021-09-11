import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

const FieldValue = require('firebase-admin').firestore.FieldValue;
const firebase_tools = require('firebase-tools');

//var serviceAccount = require("../serviceKeyDev.json");

admin.initializeApp(
    // ---------- FIREBASE EMULATOR: was maybe for storage now we have storage emulator maybe not needed
    //{credential: admin.credential.cert(serviceAccount)}
)

// makes a certain account into admin, this admin account is used as feedback related account
export const onServiceAccountCreation = functions.auth.user().onCreate(async user => {
        const userID = user.uid
        const userEmail = user.email

        if (userEmail == 'leaf.flutter@gmail.com'){
            await admin.firestore().collection('admin').doc(userID).set({})
        }
    }
);

// When a user updates his image, the data needs to be updates on other
// collections as, the copy of the image Url are placed there to be received faster
export const onProfileImageUpdate = functions.firestore
    .document('profiles/{userID}').onUpdate(async change => {
        const userID = change.before.id
        const beforeImage = change.before.data().imageUrl
        var afterImage = change.after.data().imageUrl

        if (beforeImage === afterImage) {
            console.log('Stopping since image did not change')
            return
        }

        // if user is deleted reset image to nothing so background is shown, should not pass null to ImageProvider
        if (afterImage === null){
            afterImage = ''
        }

        // find all deals and recipeints, finds all collection with name deals and joins them togheter
        const deals = await admin.firestore().collectionGroup('deals').where("uid", "==", userID).get()
        const messages = await admin.firestore().collectionGroup('recipients').where("rid", "==", userID).get()
        const promises: Promise<any>[] = []

        // Loop through deals and update image
        const dealDocs = deals.docs
        dealDocs.forEach(doc => {
            const p = doc.ref.update({
                userImage: afterImage
            })
            promises.push(p)
        })

        // Loop through chat infos and update image
        const messagesDocs = messages.docs
        messagesDocs.forEach(doc => {
            const p = doc.ref.update({
                receiverImage: afterImage
            })
            promises.push(p)
        })

        return Promise.all(promises)
    })

// When a user updates his name, the data needs to be updates on other
// collections as, the copy of the namel are placed there to be received faster
export const onProfileNameUpdate = functions.firestore
    .document('profiles/{userID}').onUpdate(async change => {
        const userID = change.before.id
        const beforeFirstname = change.before.data().firstname
        var afterFirstname = change.after.data().firstname
        const beforeLastname = change.before.data().lastname
        var afterLastname = change.after.data().lastname

        if (beforeFirstname === afterFirstname && beforeLastname === afterLastname) {
            console.log('Stopping since name did not change')
            return
        }
        // is user is deleted give default name
        if (afterFirstname === null && afterLastname === null){
            afterFirstname = 'Leaf'
            afterLastname = 'User'
        }

        // find all deals and recipeints, finds all collection with name deals and joins them togheter
        const deals = await admin.firestore().collectionGroup('deals').where("uid", "==", userID).get()
        const messages = await admin.firestore().collectionGroup('recipients').where("rid", "==", userID).get()
        const promises: Promise<any>[] = []

        // Loop through deals and update image
        const dealDocs = deals.docs
        dealDocs.forEach(doc => {
            const p = doc.ref.update({
                userName: afterFirstname + ' ' + afterLastname
            })
            promises.push(p)
        })

        // Loop through chat infos and update image
        const messagesDocs = messages.docs
        messagesDocs.forEach(doc => {
            const p = doc.ref.update({
                receiverName: afterFirstname + ' ' + afterLastname
            })
            promises.push(p)
        })

        return Promise.all(promises)
    })    
  

// Send notification when a messege is sent
export const onSendMessage = functions.firestore
    .document('chats/{senderId}/recipients/{receiverId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        // cant return before all futures are done, this wait for all to be done
        // before returning and have them be done async
        const promises: Promise<any>[] = [] // need this since the promises are of different type
        const receiverID = context.params.receiverId
        const senderID = context.params.senderId
        const messageID = context.params.messageId
        var message = snapshot.data()!.text
        const time = snapshot.data()!.time

        // get references
        const recieverRef = admin.firestore().collection('chats').doc(receiverID)
            .collection('recipients').doc(senderID)
        const recieverMessagesRef = recieverRef.collection('messages').doc(messageID)
        var messageDoc = await recieverMessagesRef.get()
        
        // dont send the notifaction to the sender, since we create the message
        // for the receivere this function runs again for sender, solution source:
        // https://stackoverflow.com/questions/57655190/cloud-functions-check-if-document-exists-always-return-exists
        if (messageDoc.exists){
            console.log('Dont send notification to himself')
            return;
        }

        // get sender info for notf
        const senderDoc = await admin.firestore().collection('profiles').doc(senderID).get()
        const firstname = senderDoc.data()!.firstname
        const lastname = senderDoc.data()!.lastname
        const senderName = firstname[0].toUpperCase() + firstname.substr(1).toLowerCase() + ' ' + lastname[0].toUpperCase() + lastname.substr(1).toLowerCase()
        const senderImage = senderDoc.data()!.imageUrl

        if (snapshot.data()!.type != 'text'){
            message = senderName + ' sent a ' + snapshot.data()!.type
        }

        // build the notification
        const type = 'message'
        const payload = {
            notification: {
                title: senderName,
                body: message,
            },
            data: {
                id: senderID,
                name: senderName,
                image: senderImage,
                message: message,
                type: type
            }
        }

        // set messageInfo for receiver
        promises.push(recieverRef.set({
            'rid': senderID,
            'time': time,
            'notification': true,
            'receiverImage': senderImage,
            'lastMessage': message,
            'receiverName': senderName
        }, { merge: true }))

        // add the message for the receiver
        var data = snapshot.data()!
        data.seen = true
        promises.push(recieverMessagesRef.set(data))

        // send the notification to the recievers topic
        promises.push(admin.messaging().sendToTopic(receiverID, payload))
        return Promise.all(promises)
    });

// Deal notifications when a new deal is added, also increment deals count 
export const onAddDeal = functions.firestore
.document('books/{bookIsbn}/deals/{dealId}')
.onCreate(async (_, context) => {
    // cant return before all futures are done, this wait for all to be done
    // before returning and have them be done async
    const promises: Promise<any>[] = [] // need this since the promises are of different type
    const bookISBN = context.params.bookIsbn

    // get book doc
    const bookDoc = await admin.firestore().collection('books').doc(bookISBN).get() 
    const bookImage = bookDoc.data()!.image
    const bookTitle = bookDoc.data()!.title[0]
    const bookMessage = 'New deal added for ' + bookTitle

    // update book deals count
    await admin.firestore().collection('books').doc(bookISBN).update({deals: FieldValue.increment(1)})


    // build the notification
    const type = 'book'
    const payload = {
        notification: {
            title: bookTitle,
            body: bookMessage,
        },
        data: {
            id: bookISBN,
            title: bookTitle,
            image: bookImage,
            message: bookMessage,
            type: type
        }
    }

    // set notification for all followers
    const followers = await admin.firestore().collectionGroup('following').where("pid", "==", bookISBN).get()
    const followersDocs = followers.docs
    followersDocs.forEach(doc => {
        const p = doc.ref.update({
            notification: true
        })
        promises.push(p)
    })

    // send the notification to the recievers topic
    promises.push(admin.messaging().sendToTopic(bookISBN, payload))
    return Promise.all(promises)
});

// Decrement deals count, when a deal is deleted, better than having it in the frontend
// because of scope and also sometimes user deleted the deal, but its not reflected in books collection
export const onDeleteDeal = functions.firestore
.document('books/{bookIsbn}/deals/{dealId}')
.onDelete(async (_, context) => {
    // get book isbn
    const bookISBN = context.params.bookIsbn
    // update book deals count
    return admin.firestore().collection('books').doc(bookISBN).update({deals: FieldValue.increment(-1)})
});

export const onAddFollow = functions.firestore
.document('profiles/{uid}/following/{followId}')
.onCreate(async (_, context) => {
    // get book isbn
    const bookISBN = context.params.followId
    // update book deals count
    return admin.firestore().collection('books').doc(bookISBN).update({follows: FieldValue.increment(1)})
});

export const onRemoveFollow = functions.firestore
.document('profiles/{uid}/following/{followId}')
.onDelete(async (_, context) => {
    // get book isbn
    const bookISBN = context.params.followId
    // update book deals count
    return admin.firestore().collection('books').doc(bookISBN).update({follows: FieldValue.increment(-1)})
});

// auth trigger (user deleted)
export const onUserDelete = functions.auth.user().onDelete(async user => {
    const promises = []
    // delete user profile
    const userDoc = admin.firestore().collection('profiles').doc(user.uid)
    promises.push(userDoc.delete())
    // delete user followings collection in profile
    const userFollowings = await admin.firestore().collection('profiles').doc(user.uid).collection('following').get();
    userFollowings.forEach(doc => {
         promises.push(doc.ref.delete())
    })
    // delete users message data
    promises.push(firebase_tools.firestore
      .delete('chats/' + user.uid, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true
      }))

    // delete users deals, finds all collection with name deals and joins them togheter
    const deals = await admin.firestore().collectionGroup('deals').where("uid", "==", user.uid).get()
    const dealDocs = deals.docs
    dealDocs.forEach(doc => {
        const p = doc.ref.delete()
        promises.push(p)
    })
    // delete user presence value from realtime database
    const presenceMap = admin.database().ref('presence').child(user.uid)
    promises.push(presenceMap.remove())

    // return when all promises are done
    return Promise.all(promises)
});