import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp()

// When a user updates his image, the data needs to be updates on other
// collections as, the copy of the image Url are placed there to be received faster
export const onProfileImageUpdate = functions.firestore
    .document('users/{userID}').onUpdate(async change => {
        const userID = change.before.id
        const beforeImage = change.before.data().imageUrl
        const afterImage = change.after.data().imageUrl

        if (beforeImage === afterImage) {
            console.log('Stopping since image did not change')
            return
        }

        // find all deals and recipeints, finds all collection with name deals and joins them togheter
        const deals = await admin.firestore().collectionGroup('deals').where("uid", "==", userID).get()
        const messages = await admin.firestore().collectionGroup('recipients').where("receiverId", "==", userID).get()
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
                userImage: afterImage
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
        const message = snapshot.data()!.text
        console.log(message)
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
        const senderName = senderDoc.data()!.firstname + ' ' + senderDoc.data()!.lastname
        const senderImage = senderDoc.data()!.imageUrl

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

        // set notification for receiver
        // const notfRef = admin.firestore().collection('notifications').doc(receiverID)
        // await notfRef.set({ 'chat': true }, { merge: true })

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

// Deal notifications when a new deal is added  
export const onAddDeal = functions.firestore
.document('books/{bookIsbn}/deals/{dealId}')
.onCreate(async (snapshot, context) => {
    // cant return before all futures are done, this wait for all to be done
    // before returning and have them be done async
    const promises: Promise<any>[] = [] // need this since the promises are of different type
    const bookISBN = context.params.bookIsbn
    const dealID = context.params.dealId
    const deal = snapshot.data()!
    console.log(deal)
    const time = snapshot.data()!.time

    // get book doc
    const bookDoc = await admin.firestore().collection('books').doc(bookISBN).get() 
    const bookImage = bookDoc.data()!.image
    const bookTitle = bookDoc.data()!.titles[0]
    const bookMessage = 'New deal added for ' + bookTitle

    // get deal adder info for notf
    // const senderDoc = await admin.firestore().collection('profiles').doc(deal.uid).get()
    // const senderName = senderDoc.data()!.firstname + ' ' + senderDoc.data()!.lastname
    // const senderImage = senderDoc.data()!.imageUrl

    // build the notification
    const type = 'book'
    const payload = {
        notification: {
            title: 'New deal',
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
    const followers = await admin.firestore().collectionGroup('book_follows').where("isbn", "==", bookISBN).get()
    const followersDocs = followers.docs
    followersDocs.forEach(doc => {
        const notfRef = admin.firestore().collection('notifications').doc(receiverID)
        const p = notfRef.set({ 'follow': true }, { merge: true })
        promises.push(p)
    })


    // send the notification to the recievers topic
    promises.push(admin.messaging().sendToTopic(bookISBN, payload))
    return Promise.all(promises)
});

// auth trigger (user deleted)
export const onUserDelete = functions.auth.user().onDelete(async user => {
    const promises = []
    // delete user data
    const userDoc = admin.firestore().collection('profiles').doc(user.uid)
    promises.push(userDoc.delete())
    // delete users message data
    const messagesDoc = admin.firestore().collection('messages').doc(user.uid)
    promises.push(messagesDoc.delete())
    // delete users deals, finds all collection with name deals and joins them togheter
    const deals = await admin.firestore().collectionGroup('deals').where("uid", "==", user.uid).get()
    const dealDocs = deals.docs
    dealDocs.forEach(doc => {
        const p = doc.ref.delete()
        promises.push(p)
    })
    // return when all promises are done
    return Promise.all(promises)
});