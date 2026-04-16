import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dashboard_screen.dart';

const String zugTermsAndConditions = """
ZUG – Terms & Conditions
(Micro-Income Support Platform)

Effective Date: [Insert Date]

By clicking “I Agree” and using the ZUG platform (“Platform”), you acknowledge that you have read, understood, and agree to be legally bound by the following Terms & Conditions.

---

PART A – NATURE OF PLATFORM

1. Platform Description
   ZUG is a technology-based platform that facilitates voluntary user contributions and may provide conditional financial support (“micro-income support”) to eligible users.

ZUG operates solely as a platform and does not function as:

* An insurance company
* A financial institution
* An investment or deposit-taking entity

---

2. Explicit Non-Insurance Declaration
   ZUG does NOT provide insurance services.

* No insurance policy is issued
* No premium is collected
* No assured benefit or compensation is guaranteed

ZUG is not regulated by the Insurance Regulatory and Development Authority of India (IRDAI) and does not operate under the Insurance Act, 1938.

Use of the Platform does not create any insurer-policyholder relationship.

---

3. Nature of Contributions
   All payments made by users are voluntary contributions to the Platform.

Such contributions:

* Are NOT insurance premiums
* Are NOT deposits under any banking or financial law
* Are NOT investments or savings instruments

Users acknowledge that contributions are made at their own discretion and do not entitle them to any guaranteed return or payout.

---

4. Discretionary Support Mechanism
   ZUG may, at its sole discretion, provide financial support to users based on internally defined eligibility conditions.

Users acknowledge that:

* Support is NOT guaranteed
* Eligibility is determined by platform-defined rules and system logic
* Decisions are final and binding

No user has a legally enforceable right to receive support.

---

5. Maximum Support Cap
   The maximum cumulative financial support that may be provided to any individual user shall not exceed ₹2,00,000 (Rupees Two Lakhs).

This limit:

* Is an internal risk-management cap
* Does not create any entitlement or assurance
* Is subject to change at ZUG’s discretion

This cap is adopted as a conservative threshold aligned with commonly observed limits in micro-benefit financial products, and does not imply that ZUG operates as an insurer.

---

6. Payments and Processing
   All payments on the Platform are processed through RBI-compliant third-party payment aggregators.

ZUG:

* Does not store card or UPI credentials
* Does not directly process or hold regulated financial instruments

---

7. No Financial Advice or Product Representation
   ZUG does not offer:

* Insurance
* Investment advice
* Lending or credit facilities

Nothing on the Platform shall be interpreted as financial advice or a promise of income protection.

---

PART B – USER OBLIGATIONS

8. User Responsibilities
   Users agree to:

* Provide accurate and truthful information
* Use the Platform lawfully
* Not engage in fraudulent, abusive, or manipulative behavior

ZUG reserves the right to suspend or terminate accounts for violations.

---

9. Fraud Prevention and Verification
   ZUG reserves the right to:

* Verify user information
* Request documentation
* Reject or reverse support in cases of suspected fraud

---

PART C – LIMITATION OF LIABILITY

10. No Guarantee of Support
    ZUG does not guarantee:

* Availability of funds
* Eligibility for support
* Continuity of the Platform

---

11. Limitation of Liability
    To the maximum extent permitted by law, ZUG shall not be liable for:

* Failure to provide support
* Loss of income or opportunity
* Indirect, incidental, or consequential damages

---

PART D – DATA AND PRIVACY

12. Data Protection
    ZUG processes personal data in accordance with applicable Indian laws, including the Digital Personal Data Protection Act, 2023.

By using the Platform, you consent to:

* Collection of necessary data
* Use of data for platform operations, fraud prevention, and compliance

---

PART E – REGULATORY POSITION

13. Intermediary Status
    ZUG operates as an intermediary technology platform and complies with applicable obligations under Indian law.

---

14. Consumer Protection Compliance
    ZUG maintains a grievance redressal mechanism and complies with applicable consumer protection requirements.

---

15. Financial Compliance
    ZUG ensures:

* Payments are routed through authorised entities
* No unauthorised financial activity is conducted
* No deposit-taking behaviour is undertaken

---

PART F – GRIEVANCE REDRESSAL

16. Grievance Mechanism
    Users may submit complaints through the Platform.

* Acknowledgement within 24 hours
* Resolution within 15 working days

---

PART G – MODIFICATIONS

17. Updates to Terms
    ZUG reserves the right to update these Terms at any time.

Continued use of the Platform constitutes acceptance of the revised Terms.

---

ACCEPTANCE

By clicking “I Agree”, you confirm that:

* You understand that ZUG does NOT provide insurance
* You understand that payouts are discretionary and NOT guaranteed
* You accept all risks associated with using the Platform
* You agree to be bound by these Terms & Conditions

---

ZUG – A Platform for Community-Based Financial Support
""";

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  bool _isAccepting = false;

  Future<void> _acceptTerms() async {
    setState(() => _isAccepting = true);
    try {
      final workerIdStr = await _storage.read(key: 'worker_id');
      if (workerIdStr != null) {
        final int workerId = int.parse(workerIdStr);
        // Attempt to update the flag in Supabase. 
        // We'll use a generic upsert or update if the column exists.
        // If the column doesn't exist, we'll still save it locally.
        try {
          await _supabase.from('workers').update({
            'terms_accepted': true,
            'terms_accepted_at': DateTime.now().toIso8601String(),
          }).eq('id', workerId);
        } catch (e) {
          debugPrint('Could not update terms_accepted in DB (maybe column missing): $e');
        }

        // Always save locally to avoid re-prompting if DB update failed or column missing
        await _storage.write(key: 'terms_accepted', value: 'true');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error accepting terms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                zugTermsAndConditions,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isAccepting ? null : _acceptTerms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isAccepting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'I AGREE',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
