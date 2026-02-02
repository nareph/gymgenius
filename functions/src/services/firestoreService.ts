import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";

export class FirestoreService {
    private db: admin.firestore.Firestore;

    constructor() {
        this.db = admin.firestore();
    }

    /**
     * Generic method to get documents from a collection with filters
     */
    async getDocuments(
        collectionPath: string,
        filters: { field: string; operator: admin.firestore.WhereFilterOp; value: any }[] = [],
        orderBy: { field: string; direction: 'asc' | 'desc' } | null = null,
        limit: number | null = null
    ): Promise<admin.firestore.QuerySnapshot> {
        try {
            let query: admin.firestore.Query = this.db.collection(collectionPath);

            // Apply filters
            filters.forEach(filter => {
                query = query.where(filter.field, filter.operator, filter.value);
            });

            // Apply ordering
            if (orderBy) {
                query = query.orderBy(orderBy.field, orderBy.direction);
            }

            // Apply limit
            if (limit) {
                query = query.limit(limit);
            }

            return await query.get();  // Return the full QuerySnapshot
        } catch (error) {
            logger.error(`Error getting documents from ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Get document by ID
     */
    async getDocument(collectionPath: string, docId: string): Promise<admin.firestore.DocumentSnapshot | null> {
        try {
            const doc = await this.db.collection(collectionPath).doc(docId).get();
            return doc.exists ? doc : null;
        } catch (error) {
            logger.error(`Error getting document ${docId} from ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Create a new document
     */
    async createDocument(collectionPath: string, data: any, docId?: string): Promise<string> {
        try {
            let docRef: admin.firestore.DocumentReference;

            if (docId) {
                docRef = this.db.collection(collectionPath).doc(docId);
                await docRef.set(data);
            } else {
                docRef = await this.db.collection(collectionPath).add(data);
            }

            return docRef.id;
        } catch (error) {
            logger.error(`Error creating document in ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Update a document
     */
    async updateDocument(collectionPath: string, docId: string, data: any): Promise<void> {
        try {
            await this.db.collection(collectionPath).doc(docId).update(data);
        } catch (error) {
            logger.error(`Error updating document ${docId} in ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Delete a document
     */
    async deleteDocument(collectionPath: string, docId: string): Promise<void> {
        try {
            await this.db.collection(collectionPath).doc(docId).delete();
        } catch (error) {
            logger.error(`Error deleting document ${docId} from ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Batch delete documents
     */
    async batchDeleteDocuments(collectionPath: string, docIds: string[]): Promise<void> {
        try {
            const batch = this.db.batch();

            docIds.forEach(docId => {
                const docRef = this.db.collection(collectionPath).doc(docId);
                batch.delete(docRef);
            });

            await batch.commit();
        } catch (error) {
            logger.error(`Error batch deleting documents from ${collectionPath}:`, error);
            throw error;
        }
    }

    /**
     * Execute a transaction
     */
    async runTransaction<T>(
        transactionHandler: (transaction: admin.firestore.Transaction) => Promise<T>
    ): Promise<T> {
        try {
            return await this.db.runTransaction(transactionHandler);
        } catch (error) {
            logger.error("Error executing transaction:", error);
            throw error;
        }
    }

    /**
     * Get collection with real-time updates (for future use)
     */
    getCollectionListener(
        collectionPath: string,
        callback: (docs: admin.firestore.QueryDocumentSnapshot[]) => void,
        filters: { field: string; operator: admin.firestore.WhereFilterOp; value: any }[] = []
    ): () => void {
        let query: admin.firestore.Query = this.db.collection(collectionPath);

        filters.forEach(filter => {
            query = query.where(filter.field, filter.operator, filter.value);
        });

        const unsubscribe = query.onSnapshot(
            (snapshot) => {
                callback(snapshot.docs);
            },
            (error) => {
                logger.error(`Error in collection listener for ${collectionPath}:`, error);
            }
        );

        return unsubscribe;
    }
}

// Export a singleton instance
export const firestoreService = new FirestoreService();