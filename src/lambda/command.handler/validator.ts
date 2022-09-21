import { getProductCategorytModel } from "./aggregation.store";
import {
  AddProductCategoryEvent,
  AddProductEvent,
  UpdateProductEvent,
} from "./events";
import { EEventType } from "../../libs/event.types";

export async function validateProductModel(
  model: any,
  event: AddProductEvent | UpdateProductEvent
) {
  if (
    model &&
    model.aggregateVersion &&
    model.aggregateVersion >= event.aggregateVersion
  ) {
    throw new Error("version mismatch");
  }

  if (event.eventType === EEventType.AddProduct) {
    if (model != null) {
      throw new Error("cannot add product that has already exist");
    }
    const catModel = await getProductCategorytModel({
      aggregateId: event.payload.categoryUuid,
      aggregateType: "Category",
    });
    if (catModel?.uuid !== event.payload.categoryUuid) {
      throw new Error("teh product category doesnt exist");
    }
  }
  if (event.eventType === EEventType.UpdateProduct) {
    if (model == null) {
      throw new Error("cannot update product, product doesnt exist");
    }
    if (
      event.payload.categoryUuid &&
      event.payload.categoryUuid !== model.categoryUuid
    ) {
      const catModel = await getProductCategorytModel({
        aggregateId: event.payload.categoryUuid,
        aggregateType: "Category",
      });
      if (catModel?.uuid !== event.payload.categoryUuid) {
        throw new Error("the product category doesnt exist");
      }
    }
  }
  if (event.eventType === EEventType.DeleteProduct && model == null) {
    throw new Error("cannot delete product, product doesnt exist");
  }
}
export async function validateProductCategoryModel(
  model: any,
  event: AddProductCategoryEvent
) {
  if (event.eventType === EEventType.AddProductCategory) {
    if (model != null) {
      throw new Error("cannot add product that has already exist");
    }
  }
}
