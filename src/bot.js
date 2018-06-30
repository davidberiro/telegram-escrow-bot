const token = process.env.TOKEN
const Bot = require('node-telegram-bot-api')
const Web3 = require(‘web3’)
const abi = (require('../build/contracts/EscrowController.json')).abi
var web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"))

const EscrowControllerContract = web3.eth.contract(abi, process.env.CONTRACT_ADDRESS)

let bot

if(process.env.NODE_ENV === 'production') {
  bot = new Bot(token);
  bot.setWebHook(process.env.HEROKU_URL + bot.token)
}
else {
  bot = new Bot(token, { polling: true })
}

console.log('Bot server started in the ' + process.env.NODE_ENV + ' mode')


module.exports = bot
