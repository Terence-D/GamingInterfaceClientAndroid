//package ca.coffeeshopstudio.gaminginterfaceclient.views
//
//import android.content.Context
//import android.os.Bundle
//import android.view.View
//import android.widget.Button
//import androidx.appcompat.app.AppCompatActivity;
//import ca.coffeeshopstudio.gaminginterfaceclient.R
//import com.android.billingclient.api.*
//
//import com.android.billingclient.api.AcknowledgePurchaseParams
//import com.android.billingclient.api.BillingFlowParams
//import android.content.Intent
//import android.content.SharedPreferences
//import android.net.Uri
//import android.os.Build
//import android.preference.PreferenceManager
//import android.text.Html
//import android.util.Log
//import android.widget.TextView
//import android.widget.Toast
//import androidx.appcompat.app.AlertDialog
//import androidx.appcompat.widget.Toolbar
//
//
//class DonateActivity : AppCompatActivity(), PurchasesUpdatedListener, View.OnClickListener, AcknowledgePurchaseResponseListener {
//  private lateinit var skuDetails:List<SkuDetails>
//  private lateinit var btnDonateA: Button
//  private lateinit var btnDonateB: Button
//  private lateinit var btnDonateWiki: Button
//  private lateinit var billingClient: BillingClient
//
//  val prefNightMode = "NIGHT_MODE"
//
//  fun darkMode () : Boolean {
//    val defaultPrefs = PreferenceManager.getDefaultSharedPreferences(applicationContext)
//    return defaultPrefs.getBoolean(prefNightMode, true)
//  }
//
//  override fun onCreate(savedInstanceState: Bundle?) {
//    if (darkMode())
//      setTheme(R.style.ActivityTheme_Primary_Base_Dark);
//
//    super.onCreate(savedInstanceState)
//    setContentView(R.layout.activity_donate)
//    val toolbar = findViewById<Toolbar>(R.id.toolbar)
//    setSupportActionBar(toolbar)
//    toolbar.setTitle(R.string.app_name)
//    toolbar.setNavigationIcon(R.drawable.ic_arrow_back_white_24dp)
//    toolbar.setNavigationOnClickListener {
//      finish()
//    }
//    btnDonateWiki = this.findViewById<Button>(R.id.btnDonateWiki)
//    btnDonateWiki.setOnClickListener(this)
//
//    val txtDonate = this.findViewById<TextView>(R.id.txtDonate)
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//      txtDonate.text = Html.fromHtml(this.getString(R.string.donation_text), Html.FROM_HTML_MODE_COMPACT)
//    } else {
//      txtDonate.text = Html.fromHtml(this.getString(R.string.donation_text))
//    }
//
//  }
//
//  override fun onResume() {
//    super.onResume()
//    initBilling()
//  }
//
//  override fun onAcknowledgePurchaseResponse(billingResult: BillingResult?) {
//    Toast.makeText(this, "Thank You!  Please restart the app to see the new Flair :)", Toast.LENGTH_SHORT).show()
//  }
//
//  override fun onClick(v: View?) {
//    when (v?.id) {
//      R.id.btnDonateA -> {
//        // Retrieve a value for "skuDetails" by calling querySkuDetailsAsync()
//        val flowParams = BillingFlowParams
//                .newBuilder()
//                .setSkuDetails(skuDetails[0])
//                .build()
//        val responseCode = billingClient.launchBillingFlow(this, flowParams)
//        if (responseCode.responseCode == 7 )
//          Toast.makeText(this, "Already Purchased!", Toast.LENGTH_SHORT).show()
//
//      }
//      R.id.btnDonateB -> {
//        // Retrieve a value for "skuDetails" by calling querySkuDetailsAsync()
//        val flowParams = BillingFlowParams
//                .newBuilder()
//                .setSkuDetails(skuDetails[1])
//                .build()
//        val responseCode = billingClient.launchBillingFlow(this, flowParams)
//        if (responseCode.responseCode == 7 )
//          Toast.makeText(this, "Already Purchased!", Toast.LENGTH_SHORT).show()
//      }
//      R.id.btnDonateWiki -> {
//        val uri = Uri.parse("https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki")
//        val intent = Intent(Intent.ACTION_VIEW, uri)
//        startActivity(intent)
//      }
//    }
//  }
//
//  override fun onPurchasesUpdated(billingResult: BillingResult?, purchases: MutableList<Purchase>?) {
//    if (billingResult != null) {
//        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
//        for (purchase in purchases) {
//          handlePurchase(purchase)
//        }
//      } else if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
//
//      } else {
//
//      }
//    }
//  }
//
//  @Suppress("DEPRECATED_IDENTITY_EQUALS")
//  private fun handlePurchase(purchase: Purchase) {
//    if (purchase.purchaseState === Purchase.PurchaseState.PURCHASED) {
//      // Grant entitlement to the user.
//      val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//      prefs.edit().putBoolean("flutter." + purchase.sku, true).apply()
//      // Acknowledge the purchase if it hasn't already been acknowledged.
//      if (!purchase.isAcknowledged) {
//        val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
//                .setPurchaseToken(purchase.purchaseToken)
//                .build()
//        billingClient.acknowledgePurchase(acknowledgePurchaseParams, this)
//      } else if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
//        showPendingDialog()
//      }
//    }
//  }
//
//  private fun updateDetails() {
//    if (skuDetails.isNotEmpty()) {
//      btnDonateA = this.findViewById(R.id.btnDonateA)
//      btnDonateA.setOnClickListener(this)
//      btnDonateA.text = "${skuDetails[0].title} ${skuDetails[0].price}"
//      btnDonateA.visibility = View.VISIBLE;
//    }
//    if (skuDetails.size > 1) {
//      btnDonateB = this.findViewById(R.id.btnDonateB)
//      btnDonateB.setOnClickListener(this)
//      btnDonateB.text = "${skuDetails[1].title} ${skuDetails[1].price}"
//      btnDonateB.visibility = View.VISIBLE;
//    }
//  }
//
//  private fun showPendingDialog() {
//    val builder = AlertDialog.Builder(this)
//    builder.setTitle("Order Pending")
//    builder.setMessage("Your purchase is listed as pending, it should be resolved in 2 days.  If you still see this please contact support@coffeeshopstudio.ca")
//    //builder.setPositiveButton("OK", DialogInterface.OnClickListener(function = x))
//    builder.setNeutralButton("Ok") { dialog, which -> }
//    builder.show()
//  }
//
//  private fun initBilling() {
//    billingClient = BillingClient.newBuilder(applicationContext).setListener(this)
//            .enablePendingPurchases()
//            .build()
//    billingClient.startConnection(object : BillingClientStateListener {
//      override fun onBillingSetupFinished(billingResult: BillingResult) {
//        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
//          val skuList = ArrayList<String>()
//          skuList.add("coffee")
//          skuList.add("star")
//          val params = SkuDetailsParams.newBuilder()
//          params.setSkusList(skuList).setType(BillingClient.SkuType.INAPP)
//          billingClient.querySkuDetailsAsync(params.build()) { queryResult, skuDetailsList ->
//            skuDetails = skuDetailsList
//            updateDetails()
//          }
//          val result = billingClient.queryPurchases(BillingClient.SkuType.INAPP)
//          if (result.billingResult.responseCode == BillingClient.BillingResponseCode.OK && result.purchasesList != null) {
//            for ( purchase in result.purchasesList)
//              handlePurchase(purchase)
//          }
//        }
//      }
//
//      override fun onBillingServiceDisconnected() {
//        // Try to restart the connection on the next request to
//        // Google Play by calling the startConnection() method.
//      }
//    })
//  }
//
//}
