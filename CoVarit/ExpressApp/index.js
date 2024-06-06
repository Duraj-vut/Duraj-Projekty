require ('dotenv').config()
const { Database, aql } = require('arangojs'); 
const { json } = require('express');
const express = require('express') 

const app = express(); 
const PORT = 3000;
let CountIng =0;
let k = -1;


const database = new Database({
    url: "http://127.0.0.1:8529", 
    databaseName: "recipes", 
    auth: {
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD
    }
})
app.use(express.json())

var dropdownValue=[];
var firstValue=[];



var jsonResults =[];
app.post("/mobileapp/search", async (req, res) => {
    k=-1;
    jsonResults =[];
    dropdownValue=[];
    firstValue=[];
    
    firstValue[0] =(String)(req.body.ingredience0);
    firstValue[1] =(String)(req.body.ingredience1);
    firstValue[2] =(String)(req.body.ingredience2);
    firstValue[3] =(String)(req.body.ingredience3);

    for(let i = 0;i<firstValue.length;i++){
        if(firstValue[i]!='Vyber surovinu')
        {dropdownValue.push(firstValue[i])}
        }
     CountIng =0;
     const idIngredience =[];
     const idIngredience2 =[];
     const resultRecipe =[];
     const filnalRecipes =[] 
     

    for(let i=0;i<dropdownValue.length;i++){
        if (dropdownValue[i]!='Vyber surovinu'){
          CountIng ++;
        }
    }
    try{
    for(let i=0;i<CountIng;i++){
        const filterByName=dropdownValue[i];
        const cursor = await database.query(aql`
            FOR doc IN Ingrediences
            FILTER doc.name == ${dropdownValue[i]}
                RETURN doc._id
        `)
        
        
        while(cursor.hasNext) {

            const doc = await cursor.next()
            idIngredience.push(doc)
        }

    const cursor2 = await database.query(aql`
        FOR v
        IN 1..50
        INBOUND ${
            idIngredience[i]
        }
        GRAPH "RecipesIngrediencesGraph"
        
        RETURN v._id
    `)
    while(cursor2.hasNext) {

        const doc = await cursor2.next()
        resultRecipe.push(doc)
        
     }
    }
    }catch(error){console.log(error)}

    for(let i=0;i<resultRecipe.length;i++){
        if((filnalRecipes.includes(resultRecipe[i]))==false){
            filnalRecipes.push(resultRecipe[i])         
        }
        }
    
    //Zmena z Id receptu na finálne hodnoty
    const RESULTS = [];
    const allING=[];
    const docIng =[];

    const numberOfIngrediences = [];
    const names = [];
    const processes = [];

    const IngNames = [];
    const IngAmounts = [];
    const IngUnits = [];
    var Counter =0;
    

    for(let i=0;i<filnalRecipes.length;i++){

         //vytiahnutie surovín
         const cursorIngrediences = await database.query(aql`
         FOR v,e
         IN 1..50
         OUTBOUND ${filnalRecipes[i]}
         GRAPH "RecipesIngrediencesGraph"
         RETURN {Ingredience: v.name, Amount: e.amount, Unit: e.unit}
         `)

         const cursorIngrediencesName = await database.query(aql`
         FOR v,e
         IN 1..50
         OUTBOUND ${filnalRecipes[i]}
         GRAPH "RecipesIngrediencesGraph"
         RETURN v.name
         `)
         const cursorIngrediencesAmount = await database.query(aql`
         FOR v,e
         IN 1..50
         OUTBOUND ${filnalRecipes[i]}
         GRAPH "RecipesIngrediencesGraph"
         RETURN e.amount
         `)
         const cursorIngrediencesUnit = await database.query(aql`
         FOR v,e
         IN 1..50
         OUTBOUND ${filnalRecipes[i]}
         GRAPH "RecipesIngrediencesGraph"
         RETURN e.unit
         `)
 
         while(cursorIngrediencesName.hasNext) {
            const ingname = await cursorIngrediencesName.next()
            IngNames.push(ingname)
            const ingamount = await cursorIngrediencesAmount.next()
            IngAmounts.push(ingamount)
            const ingunit = await cursorIngrediencesUnit.next()
            IngUnits.push(ingunit)
        }
        
        const cursor5 = await database.query(aql` 
        FOR doc2 IN Recipes
        FILTER doc2._id == ${filnalRecipes[i]}
            RETURN doc2.numberOfIngrediences
        `)
        while(cursor5.hasNext){
         const doc2 = await cursor5.next()
         numberOfIngrediences.push(doc2)
        }
        
        //ziskanie stringu name
        const cursor3 = await database.query(aql`
        FOR doc IN Recipes
        FILTER doc._id == ${filnalRecipes[i]}
            RETURN doc.name
        `)
        //ziskanie stringu process
        const cursor4 = await database.query(aql` 
        FOR doc1 IN Recipes
        FILTER doc1._id == ${filnalRecipes[i]}
            RETURN doc1.process
        `)

        
         while(cursor3.hasNext) {

        const doc = await cursor3.next()
        const doc1 = await cursor4.next()
        
        names.push(doc)
        processes.push(doc1) 
        }

        jsonResults[i] = {
            name:names[i],
            process:processes[i],
            numOfIng:numberOfIngrediences[i],
            ingrediences:  {}
                
        }
        
        for(let j =0;j<numberOfIngrediences[i];j++){
            var newIngredience = "ingredience" + j;
            jsonResults[i].ingrediences[newIngredience] =(IngNames[Counter]+" - "+IngAmounts[Counter]+" "+IngUnits[Counter] );
            Counter++;
        }
       
    }
    
   
    }
    
);

app.get("/mobileapp/getdata", async (req, res) => {
    k=k+1;
    
    console.log(jsonResults[k])
    return res.json(jsonResults[k])
    
});

app.get("/mobileapp/getnum", async (req, res) => {
    var numberOfResults = jsonResults.length  
    return res.json({number:numberOfResults})
});



app.listen(PORT , () => {
    console.log('Server is listening on port 3000...')
})