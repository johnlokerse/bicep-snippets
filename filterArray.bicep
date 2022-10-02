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

output outUsingFilter array = filter(varGroceryStore, item => item.productPrice >= 4)
