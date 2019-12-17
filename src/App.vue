<template>
  <b-container class="mb-5">
    <b-row class="header-row">
      <b-col>
        <h1>POBA TAG</h1>
        <p>Validating Collectibles With Blockchain Tokenization.</p>
      </b-col>
    </b-row>

    <b-row>
      <b-col class="action-container text-center">
        <h4>Buy a random POBA</h4>
        <img :src="unknownPOBAImg" class="unknown-POBA">
        <b-button type="button" v-on:click="buyPOBA()">Buy</b-button>
        <p>Each POBA costs 0.02 Ether</p>
      </b-col>
      <b-col cols="2" class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif">
        <h3 v-if="!isLoading">or</h3>
      </b-col>
      <b-col class="action-container">
        <h4>POBA TAG OPTIONS</h4>
        <b-form>
          <b-form-group id="Order"
                        label="Order ID:"
                        label-for="Order">
            <b-form-input id="Order"
                          v-model="Order"
                          required
                          placeholder="Enter Order ID">
            </b-form-input>
          </b-form-group>
          <b-form-group id="Serial"
                        label="Serial ID:"
                        label-for="Serial">
            <b-form-input id="Serial"
                          v-model="Serial"
                          required
                          placeholder="Enter Serial ID">
            </b-form-input>
          </b-form-group>
          <b-button v-on:click="CreatePOBAs" type="button">Create POBAs</b-button>
          <p>Createing POBAs cost 0.05 Ether</p>
        </b-form>
      </b-col>
    </b-row>

    <hr>
    <h2 class="mb-5">Owned POBAs</h2>

    <b-row v-if="POBAs.length == 0">
      <b-col>
        <h2>No POBAs owned yet!</h2>
      </b-col>
    </b-row>

    <b-row v-for="i in Math.ceil(POBAs.length / 3)" v-bind:key="i">
      <b-col cols="4" v-for="item in POBAs.slice((i - 1) * 3, i * 3)"
             v-bind:item="item"
             v-bind:key="item.id">
        <b-card style="height:400px;" class="mb-2">
          <b-img thumbnail fluid :src="item.url" class="image"/>
          <p class="card-text mt-2 text-center">
            <b>ID:</b> {{ item.id }}
            <br>
            <b>Origin:</b>
            <span v-if="item.Order == 0 && item.Serial == 0">Bought</span>
            <span v-else>{{ item.Order }} & {{ item.Serial }}</span>
          </p>
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import getWeb3 from '../contracts/web3';
import contractAbi from '../contracts/abi';
import POBA1 from './assets/POBA/1.png';
import POBA2 from './assets/POBA/2.png';
import POBA3 from './assets/POBA/3.png';
import POBA4 from './assets/POBA/4.png';
import POBA5 from './assets/POBA/5.png';
import POBA6 from './assets/POBA/6.png';
import POBAX from './assets/POBA/unknown.png';

const contractAddress = '0x55b64858a531f72B59446E19FBBB8Dc469D6e2B0';
const POBAsMap = [null, POBA1, POBA2, POBA3, POBA4, POBA5, POBA6];

export default {
  name: 'App',
  data() {
    return {
      web3: null,
      account: null,
      contractInstance: null,
      gene: null,
      Order: null,
      Serial: null,
      unknownPOBAImg: POBAX,
      POBAs: [],
      isLoading: false,
    };
  },
  mounted() {
    getWeb3().then((res) => {
      this.web3 = res;
      this.contractInstance = new this.web3.eth.Contract(contractAbi, contractAddress);
      this.web3.eth.getAccounts().then((accounts) => {
        [this.account] = accounts;
        this.getPOBAs();
      }).catch((err) => {
        console.log(err, 'err!!');
      });
    });
  },
  methods: {
    buyPOBA() {
      this.isLoading = true;
      this.contractInstance.methods.buyPOBA().send({
        from: this.account,
        value: web3.toWei(0.02, 'ether'),
      }).then((receipt) => {
        this.addPOBAFromReceipt(receipt);
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },
    CreatePOBAs() {
      this.isLoading = true;
      this.contractInstance.methods.CreatePOBAs(this.Order, this.Serial).send({
        from: this.account,
        value: web3.toWei(0.05, 'ether'),
      }).then((receipt) => {
        this.addPOBAFromReceipt(receipt);
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },
    getPOBAs() {
      this.isLoading = true;
      this.contractInstance.methods.ownedPOBAs().call({
        from: this.account,
      }).then((receipt) => {
        for (let i = 0; i < receipt.length; i += 1) {
          this.contractInstance.methods.getPOBADetails(receipt[i]).call({
            from: this.account,
          }).then((POBA) => {
            this.POBAs.push({
              id: POBA[0],
              genes: POBA[1],
              Order: POBA[2],
              Serial: POBA[3],
              url: POBAsMap[POBA[1]],
            });
          }).catch((err) => {
            console.log(err, 'err');
          });
        }
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },
    addPOBAFromReceipt(receipt) {
      this.POBAs.push({
        id: receipt.events.Birth.returnValues.POBAId,
        genes: receipt.events.Birth.returnValues.genes,
        Order: receipt.events.Birth.returnValues.OrderId,
        Serial: receipt.events.Birth.returnValues.SerialId,
        url: POBAsMap[receipt.events.Birth.returnValues.genes],
      });
    },
  },
};
</script>

<style lang="css">
@import url('https://fonts.googleapis.com/css?family=Poppins:400,500');

* {
  font-family: 'Poppins', sans-serif;
}
button {
  width: 100%;
}
.header-row {
  text-align: center;
  margin: 30px 0;
}
.action-container h4 {
  text-align: center;
  margin-bottom: 30px;
}
.action-container p {
  text-align: center;
  margin-top: 10px;
}
.middle-container {
  display: flex;
  justify-content: center;
  align-items: center;
}
.middle-container img {
  height: 100px;
}
.unknown-POBA {
  height: 180px;
  width: 180px;
  margin: 9px 0;
}
</style>
