import DS from 'ember-data';
import Ember from 'ember';
import _camelCase from 'lodash/string/camelCase';
import _toArray from 'lodash/lang/toArray';
// import _findLastKey from 'lodash/object/findLastKey';

export default DS.Model.extend({

  // Attributes
  name: DS.attr('string'),
  description: DS.attr('string'),
  slug: DS.attr('string'),
  total_on_hand: DS.attr('number'),
  available: DS.attr('boolean'),

  // Breadcrumbs
  breadcrumbs: DS.attr(),

  // Price Attributes
  price: DS.attr('string'),
  costPrice: DS.attr('string'),
  discountPrice: DS.attr('string'),

  // Installments Attributes
  hasInstallments: DS.attr("boolean"),
  installments: DS.attr(),
  hasDiscount: DS.attr('boolean'),
  discounts: DS.attr(),

  // Relationships
  images: DS.hasMany('image'),
  variantsIncludingMaster: DS.hasMany('variant'),
  productProperties: DS.hasMany('productProperty'),
  taxons: DS.hasMany('taxon'),
  filters: DS.attr(),

  //
  metaDescription: DS.attr('string'),
  metaKeywords: DS.attr('string'),
  metaTitle: DS.attr('string'),

  //Computed
  variants: Ember.computed('variantsIncludingMaster', function() {
    return this.get('variantsIncludingMaster').rejectBy('isMaster');
  }),

  master: Ember.computed('variantsIncludingMaster', function() {
    return this.get('variantsIncludingMaster').findBy('isMaster');
  }),

  image: Ember.computed('images', function() {
    let imgs = this.get('images');
    return imgs.findBy('position', 1) || imgs.findBy('position', 0);
  }),

  taxon: Ember.computed(function() {
    let taxons = {};

    this.get("taxons").forEach((taxon) => {
      let propertyName = _camelCase(taxon.get("taxonomy.name"));
      let isParent = !taxon.get("parentId");

      if(!propertyName && isParent)
        return

      taxons[propertyName] = taxon
    });

    return taxons;
  }),

  installment: Ember.computed('installments', function(){
    let installments = {}

    this.get("installments").forEach((installment) => {
      let propertyName = _camelCase(installment.name);
      let installmentsArray = _toArray(installment.installments);
      installments[propertyName] = { size: installmentsArray.length, value: installmentsArray.get("lastObject.display") }
    });

    return installments;
  }),

  discount: Ember.computed('discounts', function(){
    let discounts = {}

    this.get("discounts").forEach((discount) => {
      let propertyName = _camelCase(discount.name);
      discounts[propertyName] = discount;
    });

    return discounts;
  }),


  filter: Ember.computed('filters', function() {
    let filters = {};

    this.get("filters").forEach((parent) => {
      let propertyName = _camelCase(parent.filter.name);

      filters[propertyName] = parent;
    });

    return filters;
  })

});
