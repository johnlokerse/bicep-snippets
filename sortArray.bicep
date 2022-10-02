var varGroceryStore = [
  {
    productName: 'Icecream'
    productPrice: 5
    productCharacteristics: [
      'Vegan'
      'Seasonal'
    ]
  }
  {
    productName: 'Cheese'
    productPrice: 2
    productCharacteristics: [
      'Bio'
    ]
  }
  {
    productName: 'Banana'
    productPrice: 4
    productCharacteristics: [
      'Bio'
    ]
  }
]

output outUsingSortPrice array = sort(varGroceryStore, (a, b) => a.productPrice <= b.productPrice)

output outUsingSortAlphabetically array = sort(varGroceryStore, (a, b) => a.productName <= b.productName)
