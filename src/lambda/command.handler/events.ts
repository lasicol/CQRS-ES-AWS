import { v4 as uuid } from "uuid";
import {
  EEventType,
  IEvent,
  TEventPayloads,
  AddProductCategoryPayload,
  AddProductPayload,
  UpdateProductPayload,
} from "../../libs/event.types";

export abstract class EventBase implements IEvent {
  public eventId: string;
  public aggregateType: "Product" | "Category";
  public eventType: EEventType;
  public _aggregateVersion: number = 0;
  public payload: TEventPayloads;
  constructor(public aggregateId: string) {
    this.eventId = uuid();
  }

  generateObject() {
    return {
      eventId: this.eventId,
      aggregateType: this.aggregateType,
      eventType: this.eventType,
      aggregateVersion: this.aggregateVersion,
      aggregateId: this.aggregateId,
      payload: this.payload,
    };
  }

  public set aggregateVersion(v: number) {
    this._aggregateVersion = v;
  }

  public get aggregateVersion(): number {
    return this._aggregateVersion;
  }
}

export class AddProductEvent extends EventBase {
  constructor(public aggregateId: string, public payload: AddProductPayload) {
    super(aggregateId);
    this.aggregateType = "Product";
    this.eventType = EEventType.AddProduct;
  }
}
export class UpdateProductEvent extends EventBase {
  constructor(
    public aggregateId: string,
    public payload: UpdateProductPayload
  ) {
    super(aggregateId);
    this.aggregateType = "Product";
    this.eventType = EEventType.UpdateProduct;
  }
}
export class AddProductCategoryEvent extends EventBase {
  constructor(
    public aggregateId: string,
    public payload: AddProductCategoryPayload
  ) {
    super(aggregateId);
    this.aggregateType = "Category";
    this.eventType = EEventType.AddProductCategory;
  }
}
