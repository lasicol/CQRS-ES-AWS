export interface IEvent {
    eventId: string;
    aggregateId: string;
	aggregateVersion: number | undefined;
	aggregateType: 'Product' | 'Category';
	eventType: EEventType;
	payload: TEventPayloads;
}

export enum EEventType {
    'AddProductCategory',
    'AddProduct',
    'UpdateProduct',
    'DeleteProduct'
}

export type TEventPayloads =  AddProductPayload | UpdateProductPayload | DeleteProductPayload | AddProductCategoryPayload;

export type AddProductCategoryPayload = {
    uuid: string;
    name: string;
    parentUuid: string;
}

export type AddProductPayload = {
    uuid: string;
    name: string; 
    categoryUuid: string;
    price: number; 
    description: string; 
    parameter: Record<string, any>
}

export type UpdateProductPayload = {
    name?: string; 
    categoryUuid?: string;
    price?: number; 
    description?: string; 
    parameter?: Record<string, any>
}
export type DeleteProductPayload = {
}