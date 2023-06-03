#Attribute Types
The URI - attribute type creates a corresponding URL-typed property
The Binary- attribute type allows you to store arbitrary data, and includes an option to store larger files separately on disk.
Transformable - is handy for storing classes that conform to NSCoding – it automatically converts such classes to and from a binary representation when storing them. Since many common Foundation classes conform to NSCoding, this allows you to easily store many Foundation types directly in Core Data.

//The difference between Swift optionals and Core Data optional attributes is subtle. Swift optionals can be nil during runtime, and Core Data optional attributes can be nil at save time.

#Relationships
-Relationships names start with lower case letter,
-Delete rule when set to cascade means thats - means that the deletion will automatically carry out through the reference set to the rship, a case of notebook which has one to many rship connected to note. i.e. when we delete the notebook we want to delete all the notes in that notebook as well.
-Delete rule when set to nullify - means thats the rship from note to note to nootbook will b removed when we delete the note.
#Coredata Stack
it comprises of:
1. ManagedObjectContext
2. ManagedObjectModel
3. PersistentStore Coordinator - communicate with pesristent store such as SQLIte
4. Persistent Container
#Mark: NSFetch
NSFetchRequest -> SELECT Query
NSPredicate -> WHERE clause - syntax: 
    1. NSPredicate(format: "%K = %@", someAttributeName, someValue)
    2. NSPredicate(format: "attribute = %@", someValue)
    more abt  predicate can be found here: https://learn.udacity.com/courses/ud325/lessons/40ca2be8-0054-4be5-89c6-a8afb5dd9c2d/concepts/446f3606-86c5-412d-a3df-c17b1baa4b47
    https://academy.realm.io/posts/nspredicate-cheatsheet/
    https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001798-SW1
NSSortDescriptors -> ORDER BY

NB: To cater for case where data hasnt been saved, we can call a fun to save tose changes in appdelegate on applicationWillTerminate and applicationDidEnterBackground


#MARK: Fetched Results Controller
- FRC sits btwn ur views and ur model. it listens for the changes to the data model and when changes happens triggers logic to update your views.
![FRC](/Users/damarismuhia/Downloads/FRC.png)
NB: when using FRC, we need to empty it on viewDidDisappear
![FRCDelegateMethodForTableView](/Users/damarismuhia/Downloads/FRCDelegateMethodForTableView.png)
 - fetchedResultContoller.sections?[section].numberOfObjects ?? 0 - return number of object(row) in section
 - fetchedResultContoller.object(at: indexPath) - return the object/element at a given indexPath in the fetched result
 
 
#MARK: Generic Data Source
