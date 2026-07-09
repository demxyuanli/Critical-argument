# Failure Mode Detection and Intervention Framework for AI-Assisted Engineering

[中文](ai-failure-detection-framework.md)

> Built on the Toulmin Argumentation Model, refined through critical argumentation review, adapted for long-range vibe coding tasks.

---

## Table of Contents

1. [Original Claims and Toulmin Reconstruction](#1-original-claims-and-toulmin-reconstruction)
2. [Unified Detection Framework](#2-unified-detection-framework)
3. [Critical Argumentation Review of the Framework](#3-critical-argumentation-review-of-the-framework)
4. [Revised Framework v2](#4-revised-framework-v2)
5. [Adapting to Long-Range Vibe Coding Tasks](#5-adapting-to-long-range-vibe-coding-tasks)
6. [Limited Verification Phase](#6-limited-verification-phase)
7. [Adversarial Debate Process](#7-adversarial-debate-process)
8. [Complete Integrated Process Framework](#8-complete-integrated-process-framework)
9. [External Argumentation Dimensions (v3)](#9-external-argumentation-dimensions-v3)
10. [Framework Self-Check and Meta-Level](#10-framework-self-check-and-meta-level)

---

## 1. Original Claims and Toulmin Reconstruction

### Claim 1: Uncertain language is an error signal

**Claim**: When AI uses vague hedge words such as "possibly" or "probably" in a conclusive statement, that conclusion is likely to be wrong.

**Ground**:
- AI's token prediction mechanism is based on sampling from a probability distribution. When the model has high confidence in a knowledge path, the output token sequence is deterministic and assertive.
- Empirical observation: for problems well covered by training data (e.g., standard algorithm implementations, common API usage), AI almost never uses vague hedge words.

**Warrant**: The appearance of hedge words means the model is wavering among multiple low-confidence token branches — no candidate sequence's predicted probability exceeds the implicit "assertion threshold."

**Backing**:
- A language model's next-token prediction is essentially conditional-probability maximization. The distribution of hedge words in the training corpus is highly correlated with uncertainty contexts — humans use these words when uncertain, and the model learns this correlation.
- A quantitative experiment can be designed to verify this: for a problem set with known ground truth, measure the correlation between hedge-word density in conclusion sentences and error rate. Expectation: the higher the density, the higher the error rate.

**Rebuttal**:
- A single hedge word appearing in a risk description ("this approach may have problems under concurrency") is reasonable engineering caution, not a sign of error.
- Expert language in certain domains inherently contains cautious hedging (medicine, law); once the model learns this style, it uses hedge words even in correct conclusions.

**Qualifier**:
- This claim applies to **conclusive statements** ("the cause of the bug is X"), not **risk warnings** ("X might break under scenario Y").
- Judgment requires distinguishing "conclusion modifier" from "conditional declaration" — the former is a red flag, the latter is not.
- When hedge words stack (2+ in a row), accuracy approaches 100%; a single hedge word needs contextual judgment.

---

### Claim 2: Repeated mentions during regression iteration = cognitive drift

**Claim**: If AI repeatedly re-raises already-solved, known problems during regression iteration, then AI has entered a state of cognitive drift, and the previously produced artifacts contain significant gaps.

**Ground**:
- AI has no structured "solved" state-tracking mechanism. Its access to conversation history is statistical (via attention), not structural (via a state machine).
- In long contexts, the attention weight of early tokens decays, causing the model to "forget" discussions completed earlier.

**Warrant**: Repeatedly re-raising solved problems indicates that AI's context-extraction mechanism has failed — it cannot distinguish "old information in the history record" from "currently active unsolved problems," and therefore reactivates old patterns as if they were new discoveries.

**Backing**:
- The "lost-in-the-middle" phenomenon in attention mechanisms has been confirmed by multiple studies: information positioned in the middle of the context has a significantly lower recall rate than information at the beginning and end.
- When the context-window fill rate exceeds 60-70%, the signal-to-noise ratio begins to decline non-linearly; this is the empirical critical point for drift.

**Rebuttal**:
- If AI re-examines an old problem from a new angle ("revisiting X we discussed earlier, now that condition Y has changed we need to reassess"), this is not drift.
- Some complex problems genuinely require multiple iterations to be fully solved — repeated mentions may be a normal phenomenon in the convergence process.

**Qualifier**:
- The key distinguishing factor for a drift judgment: **whether new information is brought in**. Repeated mention + no new conclusion = drift; repeated mention + new perspective/new condition/new conclusion = iteration.
- Recommended quantitative detection tool: embedding similarity — if the semantic similarity of N consecutive rounds of output > threshold, and no new verifiable conclusion is added → judge as drift.

---

### Claim 3: Lack of a clear roadmap and reference model → non-generalizable artifacts

**Claim**: In the absence of a clearly defined phase artifact and a mature reference model, the artifacts AI produces are not generalizable — i.e., they cannot be extended to variants beyond the current specific scenario.

**Ground**:
- AI's core working mechanism is conditional-probability matching, not abstract reasoning. Its "generalization" comes from pattern overlap across diverse instances in the training data, not from an understanding of underlying principles.
- When the input contains only a single scenario description, AI's output is the maximum-likelihood estimate under that specific condition, overfitting the incidental features of the input.

**Warrant**: The essence of generalization is "extracting invariant patterns from multiple instances." When only one instance is provided (the current requirement description), AI cannot distinguish "the essential features of that instance" from "the incidental features of that instance," and therefore cannot produce generalizable output.

**Backing**:
- A classic conclusion of machine learning: the generalization error of one-shot learning is far higher than that of multi-shot learning. Few-shot prompting of LLMs works precisely because multiple examples help the model identify invariant patterns.
- The role of phase-artifact definition is equivalent to intermediate verification points — anchoring the correctness of output at each phase, preventing the accumulation and amplification of deviation.

**Rebuttal**:
- If the problem domain is sufficiently standardized (e.g., CRUD APIs, standard authentication flows), the generalizability of a single scenario description may already be sufficient — because the coverage density of similar scenarios in the training data is extremely high.
- Overly detailed process constraints may suppress AI's efficiency advantage on simple tasks.

**Qualifier**:
- The severity of the generalizability deficit is positively correlated with the **novelty** of the problem domain. The more non-standard, cross-domain, and combinatorial the problem, the more severe the consequences of lacking a reference model.
- Practical judgment threshold: if you cannot describe in one sentence "why this approach is correct," then it is likely not generalizable.

---

### Claim 4: Coding without convergence = worthless

**Claim**: Entering the coding phase before brainstorming/review/critical argumentation has reached a clear converged conclusion basically cannot yield a valuable result.

**Ground**:
- Unconverged problems in the design phase do not resolve themselves upon entering the implementation phase — they re-surface in the code as technical debt, boundary bugs, and architectural conflicts.
- AI is especially good at manufacturing "pseudo-convergence": producing a seemingly thorough summary that gives humans the illusion that the discussion has been sufficient.

**Warrant**: Convergence means the hypothesis space has been sufficiently constrained to a verifiable degree. Entering coding while unconverged is equivalent to randomly choosing an implementation starting point in an unconstrained hypothesis space — the probability of reaching the global optimum drops exponentially.

**Backing**:
- A classic conclusion of software engineering: the cost of fixing a design defect is 10x in the implementation phase and 100x in the testing phase relative to the design phase (Boehm's law).
- The "pseudo-convergence" pattern in AI conversations: AI tends to wrap unsolved problems in fluent, summary-like language, making them appear already handled.

**Rebuttal**:
- For exploratory tasks (spike/prototype), coding itself can be a means of investigation — here the "artifact" is not the code, but the information gained through coding.
- For some simple tasks, the design space is small enough that no explicit convergence criterion is needed.

**Qualifier**:
- The claim applies to **non-trivial design decisions** — i.e., where at least two reasonable alternatives exist and the choice affects the system architecture or key quality attributes.
- The minimal form of a convergence criterion: there is at least one yes/no question whose answer determines the choice of design approach, and all participants agree on that answer.

---

### Claim 5: AI's recommendations to advance must be rigorously proven

**Claim**: When AI gives a recommendation to advance the process, the optimal response strategy is to require AI to provide rigorous proof for that recommendation (provenance, refutation exclusion, boundary conditions), rather than directly adopting or rejecting it.

**Ground**:
- The quality of AI's recommendations depends heavily on the completeness of its reasoning chain. An unproven recommendation may be a "sounds reasonable" answer based on pattern matching rather than logical derivation.
- Humans reviewing AI recommendations exhibit "automation bias" — a tendency to over-trust machine-generated output.

**Warrant**: Requiring AI to prove itself shifts the burden of judgment from human back to AI, and changes the object of review from "the credibility of the conclusion" to "the traceability of the reasoning chain" — the latter is far easier for humans to verify than the former. This essentially uses AI's reasoning ability for verification rather than AI's generation ability for decision-making.

**Backing**:
- Research on chain-of-thought prompting shows that explicitly requiring reasoning steps significantly improves the accuracy of LLM output.
- Automation bias in human-AI collaboration is well documented: humans tend to accept AI recommendations without sufficient review, especially under high cognitive load.
- The principle of falsifiability (Popper): a valid engineering assertion must clearly state its failure boundary.

**Rebuttal**:
- For low-risk, quickly verifiable recommendations (e.g., syntax fixes, known API usage), three-layer proof is overkill.
- Requiring AI to prove itself cannot fully eliminate errors — AI may generate a false evidence chain during the "proof" process with equal confidence.

**Qualifier**:
- The proof requirement should be proportional to the decision risk. Three-layer proof (provenance, refutation, boundary) applies to architecture-level recommendations; for implementation details, the single provenance layer may already be sufficient.
- Even if AI's proof may contain errors, its value lies in the **structured review point** — it provides concrete propositions that humans can verify one by one, rather than a vague conclusion requiring holistic judgment.

---

### Claim 6: Long-range tasks must have a structured task document

**Claim**: If a long-range task lacks a complete task document of plan→task→target→pseudocode→verify→regression, or if future-pointing vague expressions like "next step" repeatedly appear in the execution plan, then AI has likely entered cognitive drift.

**Ground**:
- Each node in the Plan→Task→Target→Pseudocode→Verify→Regression chain is an independent verification gate; missing any link creates unconstrained degrees of freedom.
- The "next step" language pattern indicates AI is in narrative mode (whose goal is to make the conversation appear to be progressing) rather than execution mode (whose goal is to get the task done).

**Warrant**: The task document's role is to provide structural constraints on AI's generation process — each phase has a clear done condition, output format, and verification method. Without these constraints, the output space AI can choose from at each step is too large, and the probability of correctness decays exponentially with the number of steps.

**Backing**:
- The counterpart of a structured process framework in traditional software engineering: the phase-gate model (e.g., V-model, Rational Unified Process), whose design goal is precisely to prevent deviation accumulation through mandatory phased verification.
- The distinction between "narrative mode vs execution mode": an LLM's default behavior in conversation is to maintain conversational coherence — this is narrative ability. Execution ability must be guided through external constraints (verification gates, done conditions).

**Rebuttal**:
- For short-range, low-complexity tasks, the full six-phase framework is over-engineering.
- Some creative work (e.g., UI exploration, algorithm prototyping) is inherently unsuited to strict phase gating — here a more suitable framework is time-boxed exploration with explicit hypotheses.

**Qualifier**:
- The framework's strictness should be positively correlated with the task's **chain length** and **irreversibility**. The longer the chain, the more severe the deviation-accumulation effect; the more irreversible the decision (e.g., architecture selection, data migration), the more rigid the verification gates must be.
- Minimum viable version: for any task with more than 3 steps, at least a clear done criterion and a verification method for each step are required. The six-phase framework is a "sufficient condition," not a "necessary condition."

---

### Claim 7: AI's "smoothness bias" systematically masks boundary problems

**Claim**: The designs and code AI generates exhibit a systematic "smoothness bias" — regression toward normal paths and common patterns, causing boundary conditions, exceptional paths, and resource-exhaustion scenarios to be systematically absent.

**Ground**:
- The LLM training objective is to maximize the likelihood of the training data. Boundary conditions are inherently low-frequency in training data, and therefore inherently low-frequency in model output.
- Even when the prompt explicitly requires "consider boundary conditions," AI tends to generate formulaic boundary handling (catch-log-return-error) rather than a boundary strategy tailored to the specific scenario.

**Warrant**: Statistical smoothness is the LLM's core working mechanism — it seeks the "least surprising" path in the space of possibilities. Boundary conditions are boundaries precisely because they are "surprising," deviating from common patterns. The two are fundamentally in conflict.

**Backing**:
- The classic long-tail distribution conclusion in NLP: models systematically underestimate low-frequency events.
- Training-data frequency is not the only cause of this bias — autoregressive generation dynamics themselves also exert smoothing pressure: even if the model "knows" a boundary condition, it still tends to follow the highest-probability path during generation, because although temperature sampling has randomness, the high-probability path has an exponential advantage at each step.

**Rebuttal**:
- Explicit enumeration of boundary conditions (listing all boundaries to be handled in the prompt) can significantly improve coverage.
- For some domains, AI's "average case" may already be handled more comprehensively than a human would.

**Qualifier**:
- Patch approach: explicitly require a boundary-condition matrix in the acceptance criteria; each boundary must correspond to a handling strategy or an explicit "not handled" declaration.
- The severity of this bias is positively correlated with the system's **fault-tolerance requirements**. For safety-critical systems, this bias is unacceptable; for prototypes/MVPs, it may be tolerable.

---

### Claim 8: AI's hallucination accumulation about "completed work"

**Claim**: AI lacks a real execution feedback loop, causing it to progressively escalate assumptions into "confirmed facts" without verification, and to keep stacking reasoning on top of erroneous foundations.

**Ground**:
- Human engineers get mandatory reality feedback through compilation errors, test failures, and runtime exceptions. AI has no such feedback loop — all its "completion" claims are at the text level, not the execution level.
- In long conversations, AI will cite assumptions from early rounds as facts in later rounds, and the confidence of the citation does not decay with the distance between the assumption and its verification.

**Warrant**: Maintaining truthfulness depends on a feedback loop. When the feedback loop is absent, errors can propagate indefinitely without correction, and each layer of propagation retains the same surface-level confidence — this is precisely the definition of "hallucination accumulation."

**Backing**:
- The "hallucination snowball" phenomenon: an early hallucination contaminates all subsequent reasoning steps that depend on it, and the model does not "realize" the error of the early step in later steps.
- Two mechanisms need to be distinguished: **memory-based hallucination accumulation** (later rounds "remember" the early error, mitigable by context management) and **inference-based hallucination accumulation** (the same error is re-inferred, rooted in the model's knowledge bias, and cannot be eliminated even by a context reset).

**Rebuttal**:
- Practices such as compiler-driven development and TDD can provide an external feedback loop to mitigate this problem.
- For purely analytical tasks (not involving executable code), the absence of verification is inherent — here other forms of cross-validation are needed (multi-source corroboration, refutation testing).

**Qualifier**:
- Mitigation strategy: forcibly insert a **verification gate** — any "completed/fixed/confirmed" claim must be accompanied by an executable verification result. The verification gate is a rigid constraint; AI cannot cross a phase boundary without verification.
- Distinguishing detection: the same error still appears after a context reset = model knowledge bias; appears only in long contexts = context contamination.

---

## 2. Unified Detection Framework

### L0: Instant Signal Layer

Low cost, high false-positive rate, used to trigger attention. L0 makes no judgment, only flags.

| # | Signal | Detection method | Meaning | Non-error interpretation |
|---|------|---------|------|-----------|
| 1 | Hedge-word density in conclusion sentences > threshold | Density statistics of "possibly/probably/perhaps" in conclusion sentences | The model's internal confidence in the conclusion is insufficient | Pragmatic style transfer, safety-alignment generalization |
| 2 | Adjacent-turn semantic similarity > threshold | Embedding cosine similarity of adjacent-turn output | Possible context saturation | Normal iterative convergence process |
| 6 | Sudden spike in "next step/then" density | Density of future-pointing vague expressions in the execution plan | Narrative mode activated | Legitimate phased summary |
| 7 | Low boundary-handling coverage | Proportion of "formulaic handling" in the generated error handling | Smoothness bias active | The current feature's boundary conditions are genuinely simple |
| S | Human response-time decay (vibe-specific) | Shortening of the time interval between two human correction requests | Attention decay | The feature genuinely became simpler |

### L1: Verification Layer

Medium cost, reduces false positives. Executes verification rather than presumption on the problems flagged by L0.

- **Hedge-word flag** → require AI to give a definitive assertion for the conclusion or explicitly declare "I am uncertain"
- **Repetition flag** → check whether the repetition introduces new information or a new condition
- **Narrative flag** → check whether the most recent done claim is accompanied by verification
- **Boundary flag** → require a list of boundary conditions not handled in the current code
- **Attention flag** → check whether the human's recent feedback contains substantive corrections

**L1 verification fails → judge as a problem signal. L1 verification passes → clear the L0 flag.**

### L2: Structural Layer

Preventive, not dependent on signal triggers.

- Complexity assessment of the task (chain length > N? irreversible decision? novel domain?)
- Choose the strictness of the process framework based on complexity (lightweight/standard/strict)
- Mandatory verification gates (number proportional to complexity)

### Unified Signal Table (Toulmin-enhanced version)

| # | Claim | Key Warrant | Actionable detection method | Rebuttal exclusion condition |
|---|------|-----------|----------------|-------------|
| 1 | Hedge words = error signal | Probability-collapse failure | Hedge-word density statistics in conclusion sentences | Limited to **conclusion modifiers**, excludes risk warnings |
| 2 | Repeated mention = drift | Context-extraction mechanism failure | Adjacent-turn embedding similarity + logical coherence check | Repetition that **brings new information** is not drift |
| 3 | No reference model = no generalization | Lack of constraints → insufficient pattern-retrieval SNR | Check whether a diversity-coverage criterion exists | Highly standardized domains can be exempted |
| 4 | Coding without convergence = worthless | Random starting point in unconstrained hypothesis space | Check whether a yes/no convergence criterion exists | Exploratory spikes can be exempted |
| 5 | Recommendations to advance must self-prove | Judgment-burden shift + reviewability | Boundary proof first → refutation → provenance | Risk proportional to proof depth |
| 6 | No task document = drift risk↑ | No verification gate → deviation accumulation | Split into risk claim (6a) and judgment claim (6b) | Tasks with chain length ≤3 can use the simplified version |
| 7 | Smoothness bias masks boundaries | Boundary conditions conflict with training distribution + autoregressive generation dynamics | Boundary-condition matrix coverage | Safety-critical cannot be exempted |
| 8 | Hallucination accumulation on "completed work" | No feedback loop → error propagation | Existence of verification gates between phases | Purely analytical tasks need cross-validation |
| 9 | Confirmatory review equals no review | "Find confirming evidence" vs "find disconfirming evidence" are different cognitive modes | Whether the reviewer aims to refute | Output below single-person comprehension complexity is exempt |

---

## 3. Critical Argumentation Review of the Framework

Placing the framework itself under the Toulmin model for meta-level review.

### 3.1 Reflexivity Test of the Framework

Does the framework violate its own rules?

| Framework rule | Self-check result |
|---------|---------|
| Rule 1: Hedge words in a conclusion sentence = error | The framework heavily uses "likely" and "possibly" as Qualifiers, but these modify **claim strength** rather than the conclusion itself. **Pass** |
| Rule 2: Repeated mention = drift | Both Claim 2 and Claim 6 mention "drift," but they discuss two different mechanisms (context decay vs missing verification gate). **Pass** |
| Rule 5: Recommendations must self-prove | The framework provides the Toulmin six-element structure, which constitutes self-proof. But the Ground layer generally relies on empirical observation and mechanistic reasoning rather than controlled experiments. **Partial pass** |
| Rule 6: Must have a task document | The framework itself is a reference model rather than a task. **Not applicable** |
| Rule 8: Verification gate | The framework does include a Rebuttal and Qualifier for each claim. **Pass** |

**Key finding**: The framework's epistemological basis is inferential rather than experimental. The Ground is largely built on "reasoning about LLM working mechanisms" and "empirical observation." Under Rule 5's three-layer proof standard (provenance/refutation/boundary), the framework's Ground layer passes only provenance, failing refutation and boundary — it does not systematically exclude alternative explanations.

### 3.2 Logical Gaps by Claim

#### Gap in Claim 1: Three interpretations of hedge words

Hedge words have at least three mutually non-exclusive interpretations:
1. **Probability-collapse failure** (adopted by the framework): the model is genuinely uncertain
2. **Pragmatic style transfer**: experts use hedge words in the training data, and the model learns the pragmatic pattern
3. **Safety-alignment effect**: RLHF training encourages cautious expression, which may over-generalize

The framework's Warrant covers only interpretation 1, without excluding interpretations 2 and 3. Detecting a hedge word can only be judged as "some source of uncertainty exists," not as "the conclusion is wrong."

**Correction**: Downgrade the Claim from "the conclusion is likely wrong" to "the conclusion lacks reliable assurance."

#### Gap in Claim 2: Logical coherence vs semantic similarity

Embedding similarity detects semantic repetition, but the essence of drift is a **break in logical coherence**. The most dangerous form of drift is generating content with high semantic novelty but completely broken logic — embedding detection will miss it.

**Correction**: Add a logical-coherence detection dimension — check whether the new output is logically consistent with the confirmed conclusions.

#### Gap in Claim 3: Correlation ≠ causation (most severe)

The Warrant claims that "generalization requires multiple instances to extract invariant patterns." But the LLM has already seen a vast number of instances during pretraining. The real mediating variable is **pattern-retrieval precision** — a reference model improves retrieval precision, but it is not the only path. Other means of constraint (acceptance criteria, interface definitions, boundary enumeration) may be equally effective.

**Correction**: Revise the Warrant from "single samples cannot abstract" to "in the absence of constraints, the signal-to-noise ratio of pattern retrieval is insufficient to guarantee generalization."

#### Gap in Claim 4: The sufficiency of the convergence criterion itself

"A yes/no question exists and the answer is agreed upon" as a convergence criterion sidesteps a harder problem: **who judges whether that yes/no question is the correct convergence criterion?** A wrongly chosen convergence criterion may lead to premature convergence (efficiently building on a wrong premise) or over-convergence (arguing over irrelevant details).

**Correction**: Add a preliminary step — "sufficiency check of the convergence criterion." Minimal form: does it cover (a) core functional correctness (b) key quality attributes (c) known risk scenarios.

#### Gap in Claim 5: The reliability of AI's proving ability

"Requiring AI to self-prove" implies an untested assumption: that AI's proving ability has the same (or higher) reliability as its generation ability. AI may produce **circular arguments** (using a rephrasing of the conclusion to "prove" the conclusion), **false provenance** (pointing to a nonexistent code snippet), or **authority hallucination** (citing a fictitious source).

**Correction**: Reliability ranking of the three-layer proof: boundary > refutation > provenance. Prioritize requiring AI to prove "under what conditions this recommendation would fail" — the hardest to fabricate, because it requires an understanding of the problem's structure.

#### Gap in Claim 6: Missing task document ≠ drift has occurred

A missing task document is a **structural condition** — it makes drift more likely to occur, but is not equivalent to drift having occurred. "Next step" language reflects the LLM's narrative tendency, and that narrative tendency also exists when there is no drift.

**Correction**: Split the Claim into two independent claims:
- 6a: Missing structured task document → drift **risk** rises significantly (conditional claim, weak)
- 6b: Output quality decay + missing task document → drift **has occurred** (joint judgment, strong)

#### Gap in Claim 7: Two mechanisms conflated

The framework attributes the smoothness bias to training-data frequency, ignoring the smoothing pressure of autoregressive generation dynamics themselves. Even when the prompt explicitly requires handling boundary conditions, AI may naturally drift back to the high-probability path during generation.

**Correction**: Extend the Warrant to "training-data frequency + the smoothing pressure of autoregressive generation dynamics."

#### Gap in Claim 8: Memory-based vs inference-based hallucination

The framework does not distinguish two mechanisms:
- **Memory-based hallucination accumulation**: later rounds "remember" the early erroneous generation (mitigable by context management)
- **Inference-based hallucination accumulation**: the same error is re-inferred (rooted in the model's knowledge bias, and cannot be eliminated even by a context reset)

**Correction**: Add a detection distinction — the same error still appears after a context reset = mechanism 2 (knowledge bias); appears only in long contexts = mechanism 1 (context contamination).

### 3.3 Global Defects of the Framework

#### Missing dimension 1: Cost-benefit analysis

The framework implicitly assumes "correctness maximization" is the only goal. In reality there is a correctness-speed Pareto frontier. The framework provides no guidance: under what circumstances can certain parts of the framework be used in a downgraded form?

#### Missing dimension 2: The cognitive load of human-AI collaboration

8 detection signals + the exclusion condition for each signal + three-layer proof + a six-phase task document — the framework's own cognitive load may cause the operator to abandon applying the framework, or the framework's application itself may become a new source of error. **A framework so complex that it cannot be reliably executed may have negative net value.**

#### Missing dimension 3: Differentiation by task type

The framework treats "AI-assisted software engineering" as a homogeneous activity. In reality scenarios differ enormously: exploratory tasks vs implementation tasks, greenfield projects vs brownfield projects, solo projects vs team projects, clear specs vs vague requirements. The detection framework applicable to each combination should differ.

#### Missing dimension 4: The evolution of AI capabilities

The framework must distinguish two kinds of limitation:
- **Structural limitations** (autoregressive generation, no real feedback loop, no persistent state) — will not disappear as models scale up
- **Current capability limitations** (context-window size, reasoning depth, domain-specific knowledge gaps) — will improve with model iteration

The current framework conflates the two.

---

## 4. Revised Framework v2

Based on the critical review results, the framework evolves from a "detection checklist" into a "layered verification protocol."

### Layered Detection Model

```
L0 Signal Layer (continuous monitoring, zero-cost flagging)
  ├─ Makes no judgment, only flags
  └─ Flag triggers →
L1 Verification Layer (on-demand verification, judges signal truth)
  ├─ Verification passes → clear flag
  └─ Verification fails → judge as problem signal →
L2 Intervention Layer (blocks progress, requires correction or downgrade)

L2 Structural Layer (independent of signals, set at task start)
  → Task complexity assessment
  → Process framework selection (lightweight/standard/strict)
  → Verification gate setup
```

### Revised Meta-Framework

| Claim | Revision | Self-check result |
|------|---------|---------|
| Hedge words | Claim downgraded from "error" to "insufficient confidence," alternative explanations added | Rebuttal more complete |
| Repetition = drift | Logical-coherence dimension added, false-positive sources distinguished | Qualifier more precise |
| No reference = no generalization | Warrant revised to "pattern-retrieval SNR," causal fallacy removed | Warrant more robust |
| Coding without convergence | Meta-check of convergence-criterion sufficiency added | Recursion problem annotated |
| Recommendations must self-prove | Three-layer proof priority ranking: boundary > refutation > provenance | Operability improved |
| No task document = drift | Split into risk claim (6a) and judgment claim (6b) | Logical gap closed |
| Smoothness bias | Autoregressive-dynamics mechanism added | Attribution more complete |
| Hallucination accumulation | Memory-based vs inference-based distinguished, different countermeasures | Mechanism more precise |
| Missing dimensions | Cost-benefit, cognitive load, task differentiation, capability evolution added | Coverage expanded |

---

## 5. Adapting to Long-Range Vibe Coding Tasks

### 5.1 The Essence of Vibe Coding and Its Tension with the Framework

The premise of vibe coding (Karpathy, 2025) is not "AI will write correct code," but "**my cost to verify code is far lower than my cost to write code.**"

This is in fundamental tension with the framework — the framework pursues process rigor, while vibe coding pursues process minimalism. **Directly applying the framework to constrain vibe coding is equivalent to killing vibe coding itself.**

A more effective approach: reposition the framework as a **mode-transition detector** — identifying when vibe coding shifts from an effective mode to a failure mode, triggering a mode switch.

### 5.2 The Four Implicit Assumptions of Vibe Coding and Their Breaking Conditions

#### Assumption 1: A short feedback loop is equivalent to high-quality design

- **Holds when**: the cost of a single iteration ≤ the cost of upfront design; errors can be identified and corrected within 1-2 rounds
- **Breaks when**: errors are only exposed after N subsequent rounds (coupling delay); the accumulated cost of correction exceeds the upfront design cost
- **Key signal**: the approach AI proposes in round K has a hidden conflict with round K-N

#### Assumption 2: AI's training distribution covers the problem space

- **Holds when**: the problem domain is highly standardized (CRUD, standard UI patterns, common library usage); requirements map to known patterns
- **Breaks when**: cross-domain combinations (e.g., "a collaborative document editor rendered with WebGL"); obscure domains
- **Key signal**: AI starts using hedge words to modify core logic rather than merely as risk warnings

#### Assumption 3: Vibe-check is an effective verification mechanism

- **Holds when**: errors are surface-visible (UI crash, obviously wrong output); the system state space is small
- **Breaks when**: logical errors (a 3% deviation in the computed result, imperceptible by eye); security errors; cumulative errors
- **Key signal**: the feature "looks fine" but lacks an executable verification criterion

#### Assumption 4: The task can be decomposed into independent vibe-size chunks

- **Holds when**: component boundaries are naturally clear (independent API endpoints); no cross-component consistency constraints
- **Breaks when**: modifying module A implicitly changes assumptions in module B; a data-model change requires migrating all dependents
- **Key signal**: a modification in one vibe iteration triggers an unexpected bug in another module

### 5.3 Failure Modes Specific to Vibe Coding

#### Specific pattern A: Version-confusion drift

In a long vibe session, AI accumulates multiple code versions of the same feature in the context, and may mix elements from different versions — referencing a v1 data structure alongside a v3 function signature.

**Detection**: at a structured insertion, require AI to output the full interface list of the current version. Multiple inconsistent definitions of the same symbol → version confusion.

#### Specific pattern B: Vibe decay of human attention

The vibe-check quality at round 50 is far lower than at round 5. Humans begin "glancing and passing" not because the code is fine, but because they are tired.

**Detection**: statistical change in human response time (faster and faster = decay); correction requests shift from concrete fixes to "close enough," "let's leave it for now."

#### Specific pattern C: Vibe inertia

Even when aware that "a redesign may be needed," the vibe rhythm drives one to continue rather than stop to reflect. It feels like "just one more try," but each attempt is actually adding technical debt.

**Detection**: N consecutive iterations produce no substantive functional increment (only style tweaks, back-and-forth). When the iteration density (rounds/functional increment) exceeds a preset threshold → forcibly trigger a structured insertion.

### 5.4 The Mode-Transition Protocol for Vibe Coding

```
┌─────────────────────────────────────────────────────┐
│                  VIBE CODING MODE                    │
│  L0 signals continuously monitored (zero-cost)       │
│                                                     │
│  ├─ No L0 signal triggered → continue vibe, no extra action │
│  │                                                   │
│  ├─ 1-2 L0 triggers → L1 quick verification (done within 1-2 turns) │
│  │   ├─ Verification passes → clear flag, continue vibe │
│  │   └─ Verification fails → mark as yellow state    │
│  │                                                   │
│  └─ 3+ L0 triggers OR 3 consecutive yellow rounds → trigger mode transition │
│      ↓                                               │
│  ┌─────────────────────────────────────────────┐     │
│  │      Structured Insertion (not a mode switch)  │     │
│  │  1. State inventory: which parts are currently │     │
│  │     confirmed correct?                         │     │
│  │  2. Assumption list: which assumptions are     │     │
│  │     currently unverified?                      │     │
│  │  3. Risk flag: which module is most likely to  │     │
│  │     break?                                     │     │
│  │  4. Convergence criterion: what counts as      │     │
│  │     "done" for the current phase?              │     │
│  │                                                │     │
│  │  When complete → return to vibe mode           │     │
│  └─────────────────────────────────────────────┘     │
│      ↓ (if L0 signals still trigger after insertion)   │
│  ┌─────────────────────────────────────────────┐     │
│  │           Full Mode Switch                     │     │
│  │  Abandon vibe mode, switch to structured      │     │
│  │  p→t→t→p→v→r process                          │     │
│  │  Start from current code state, supplement    │     │
│  │  complete design and verification             │     │
│  └─────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────┘
```

### 5.5 Vibe Coding Safety Boundaries

| Dimension | Safe zone | Danger zone | Detection signal |
|------|--------|--------|---------|
| Session length | Completable in a single session | Requires continuation across sessions | AI cannot recite key decisions across sessions |
| Code scale | <5 files, <500 lines | >10 files, >2000 lines | Threshold triggers structured insertion |
| Problem novelty | Coverable by standard patterns | Cross-domain combination/obscure domain | Hedge words modifying core logic |
| Verification method | Errors are surface-visible | Errors require logical reasoning | Gap between AI's summary description and code behavior |
| Coupling degree | Loosely coupled components | Cross-component consistency constraints | One iteration's side effect affects multiple modules |
| Correctness requirement | Prototype/MVP/personal tool | Production system/safety-critical | Ratio of erroneous business impact to vibe-check reliability |

---

## 6. Limited Verification Phase

### 6.1 Toulmin Argument

**Claim**: In any non-trivial task, a time-limited structured verification phase must be inserted before coding begins. For tasks lacking this phase, the quality variance of the coding result is uncontrollable — it may be correct, it may be catastrophically wrong, and the two cannot be distinguished in advance.

**Ground**:
1. The human-AI consensus in the design phase contains systematic blind spots. AI tends to wrap unsolved problems in fluent summaries, and humans accept AI's "sounds reasonable" conclusions when under high cognitive load.
2. The cost of fixing a design defect grows exponentially by phase: 1x in the design phase, 10x in the coding phase, 100x in the testing phase (Boehm, 1981).
3. AI accelerated design, but it also accelerated the speed at which **wrong design** is pushed into coding — the speed amplifier acts indiscriminately on correct and incorrect alike.

**Warrant**: The error-discovery mechanisms of the design phase and the production phase are fundamentally different. The design phase discovers errors through logical analysis (checking assumption consistency, boundary completeness, constraint satisfaction), while the production phase discovers errors through execution feedback (compilation errors, test failures). Logical analysis can exclude an entire class of errors without incurring code cost, whereas execution feedback can only verify what you thought to test.

**Backing**:
- Lightweight design verification can catch 40-60% of downstream implementation bugs (McConnell, 2004)
- AI performs significantly better at "generating code from a design" than at "generating correct code without a design." A design document provides AI with a constraint gradient.
- Humans have an "illusion of explanatory depth" — AI's fluent output amplifies this illusion.

**Rebuttal**:
1. **"Slows things down"** — counter: the verification phase is capped at 10-15% of time, and the errors it catches take 3-5x longer to fix in the coding phase.
2. **"Prototypes don't need it"** — counter: exploratory prototypes can be exempted, but after the prototype ends, the assumptions that need verification must be explicitly declared.
3. **"Some designs can only be verified during coding"** — counter: limited verification does not require verifying everything, only "the part that can be verified before coding"; the rest is marked as deferred verification.
4. **"AI can self-correct"** — counter: this is precisely the erroneous assumption the framework tries to prevent. AI self-correction is unreliable without an external feedback loop.

**Qualifier**:
- Applies: the task involves ≥2 module interactions OR ≥1 irreversible decision
- Does not apply: single-file scripts, one-off data transformations, pure configuration changes
- Time budget: 10-15% of total time, hard cap 2 hours
- Depth grading: lightweight (prototype) → standard (feature development) → strict (safety-critical)

### 6.2 The Four-Layer Check of Limited Verification

```
═══════════════════════════════════════════════════
       PRE-CODING LIMITED VERIFICATION PHASE (10-15% time budget)
═══════════════════════════════════════════════════

L1: Assumption inventory (2-3 min)
┌─────────────────────────────────────────────────┐
│ Action: list every assumption the current design │
│         depends on, one by one                   │
│                                                 │
│ For each assumption, answer:                     │
│   "If this assumption does not hold, which part  │
│    of the design collapses?"                     │
│                                                 │
│ Output: assumption list + risk level of each     │
│         (high/medium/low)                        │
│                                                 │
│ Pass condition: all high-risk assumptions have a │
│          corresponding mitigation strategy       │
│          or an explicit "accept this risk"       │
│          declaration                             │
│                                                 │
│ Typical finding: "We assume the API always       │
│           returns an ordered list — if it is     │
│           unordered, the sort logic silently     │
│           fails"                                 │
└─────────────────────────────────────────────────┘
    ↓ pass
L2: Boundary-condition matrix (3-5 min)
┌─────────────────────────────────────────────────┐
│ Action: for each input/state dimension, list the │
│         boundary values and handling strategies  │
│                                                 │
│ Dimension examples:                              │
│   - Input: null, empty, single element, max      │
│     value, illegal type                          │
│   - State: initial, intermediate, complete,      │
│     timeout, concurrent conflict                 │
│   - Environment: network down, disk full, out of │
│     memory, insufficient permissions             │
│                                                 │
│ Output: boundary × handling-strategy matrix      │
│                                                 │
│ Pass condition: every boundary has a handling    │
│          strategy or an explicit "not handled"   │
│          declaration                             │
│                                                 │
│ Typical finding: "20% of the boundaries in the   │
│           table have no corresponding handling    │
│           logic; the current design is undefined  │
│           under empty input"                     │
└─────────────────────────────────────────────────┘
    ↓ pass
L3: Failure-mode walkthrough (5-10 min)
┌─────────────────────────────────────────────────┐
│ Action: for each key module, answer:             │
│   "What are the three most likely ways this      │
│    module fails?"                                │
│   "What is the blast radius of each failure?"    │
│   "Is there a failure that would crash the       │
│    entire system?"                               │
│                                                 │
│ Output: failure-mode list + impact analysis +    │
│         mitigation strategy                      │
│                                                 │
│ Pass condition: every single point of failure    │
│          has a degradation strategy              │
│          or an explicit "accept single-point-    │
│          of-failure risk" declaration            │
│                                                 │
│ Typical finding: "Three modules all depend on    │
│           the same cache-key format — any change  │
│           to it silently breaks the other two"   │
└─────────────────────────────────────────────────┘
    ↓ pass
L4: "One thing that kills the design" test (2-3 min)
┌─────────────────────────────────────────────────┐
│ Action: answer one question:                     │
│   "If one thing —                    one thing — │
│    were found to be wrong, and the entire design │
│    would need to be torn down and redone,        │
│    what is that one thing?"                      │
│                                                 │
│ Then follow up: "How confident are we that this  │
│                  one thing is right?"            │
│                                                 │
│ Output: the one-sentence fatal assumption +      │
│         confidence assessment                    │
│                                                 │
│ Pass condition: the fatal assumption's           │
│          confidence ≥ acceptable threshold       │
│          or the Task scope is narrowed to avoid  │
│          the assumption                          │
│                                                 │
│ Typical finding: "We assume a user's phone       │
│           number and account are one-to-one — if │
│           multiple accounts share a phone number, │
│           the entire authentication design needs  │
│           to be redone."                         │
└─────────────────────────────────────────────────┘

All L1-L4 pass → enter coding
Any layer fails → return to design correction, do not enter coding
```

### 6.3 Minimal Vibe Coding Adaptation (30-second version)

```
VIBE CHECKPOINT (30 seconds before coding):
1. Which three assumptions, if wrong, would ruin this code?
2. If the input is null/empty/oversized, will the code blow up or fail silently?
3. What is the most likely way it fails?

AI must output these three sentences before starting to code.
The human spends 30 seconds reading them. Any one triggering an intuitive
alarm → do not code, clarify first.
```

---

## 7. Adversarial Debate Process

### 7.1 Toulmin Argument

**Claim**: Any non-trivial artifact produced by AI must, before being marked "complete," undergo a structured adversarial debate process — a process specifically designed to REFUTE the artifact, not merely to REVIEW it. Artifact review that lacks adversarial debate is, in a statistical sense, not significantly different from no review.

**Ground**:
1. When humans review AI output, automation bias and confirmation bias act together — they tend to look for "right" evidence rather than "wrong" evidence.
2. The statistical smoothness of AI output (consistent code style, clear structure) is subconsciously used by humans as a "correctness proxy metric," but has no causal relationship with correctness.
3. A single reviewer is limited by their own knowledge boundary and mental set. The novel errors AI introduces (based on a wrong assumption but logically correct; superficially complete but missing coverage) may be entirely outside the reviewer's cognitive range.

**Warrant**: Adversarial debate changes the **objective function** of review. Standard review: goal = assess correctness, output = "does it look right." Adversarial debate: goal = find refutation, output = "where is it wrong + why." These two objective functions are completely different in their search space.

**Backing**:
- In medical diagnosis, "devil's advocate" review reduces the misdiagnosis rate by 30-40%
- In software security audits, the "red team" mode discovers 80% of the high-risk vulnerabilities missed by routine review
- Cognitive science: when a person is asked to "find errors," analytical thinking is activated; when asked to "assess quality," heuristic thinking is activated

**Rebuttal**:
1. **"Too time-consuming"** — counter: time should be proportional to risk. Low risk = 30 seconds, high risk = several hours. The comparison is between verification cost and the expected loss of not verifying.
2. **"No adversary exists"** — counter: the same AI can produce effective refutation after switching prompt roles. The key is structured debate — not asking "is there a problem with this" (it says "no"), but asking "list three scenarios where this code could cause a production incident."
3. **"Infinite loop"** — counter: set a hard termination condition — N rounds, or new arguments overlap old ones by >80%.
4. **"Hurts morale"** — counter: the target of adversarial debate is the work product, and the goal is to find fixable problems. Correct implementation should increase the team's confidence in the final artifact.

**Qualifier**:
- Applies: any non-trivial AI artifact marked "complete" or "deliverable"
- Debate depth: L1 lightweight (single-round refutation) → L2 standard (three structured rounds) → L3 strict (multi-role, multi-angle)
- Termination condition: (a) N rounds complete (b) new arguments have >80% semantic overlap (c) all known risks have a mitigation or acceptance declaration
- Source of the adversary: same AI with an adversarial prompt [lowest cost] → a different AI model [cognitive diversity] → human adversary [highest quality]

### 7.2 The Three-Round Structure of Adversarial Debate

```
═══════════════════════════════════════════════════
          ARTIFACT REVIEW AND ADVERSARIAL DEBATE PROCESS
═══════════════════════════════════════════════════

Input: the artifact produced by AI (code, design, analytical
       conclusion) + the original requirement

┌─────────────────────────────────────────────────┐
│ ROUND 1: Structural challenge                    │
│                                                 │
│ Adversary role: "I will prove this artifact has  │
│                  defects along the following      │
│                  dimensions"                      │
│                                                 │
│ Attack dimensions:                               │
│   D1 - Correctness: is there an input that makes │
│        the output wrong?                          │
│   D2 - Completeness: does it cover all declared  │
│        requirements?                              │
│   D3 - Consistency: is there an internal logical │
│        contradiction?                            │
│   D4 - Robustness: is the behavior defined under │
│        boundary conditions?                       │
│   D5 - Security: is there an exploitable         │
│        vulnerability?                             │
│   D6 - Maintainability: does modifying one       │
│        module require chained modifications?      │
│                                                 │
│ Output: a specific challenge per dimension +     │
│         evidence                                 │
│   "On dimension D1, I found that when X=null,    │
│    line Y throws an NPE, but the docs claim null │
│    input is supported."                          │
└─────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────┐
│ ROUND 2: Artifact side responds                  │
│                                                 │
│ For each challenge from Round 1, respond one by  │
│ one:                                            │
│                                                 │
│   [Accept] "This is a real defect. Fix: ..."     │
│   [Refute] "This challenge does not hold,        │
│            because... (provide evidence)"        │
│   [Clarify] "The challenge is based on a         │
│             misunderstanding. The actual         │
│             behavior is..."                      │
│   [Demote] "This is a known limitation, already  │
│            explicitly declared as not handled"   │
│                                                 │
│ Forbidden responses:                             │
│   [Ignore] no response = accept by default       │
│   [Vague] "this should be fine" = treated as no  │
│           response                               │
└─────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────┐
│ ROUND 3: Adversary rebuttal + final verdict      │
│                                                 │
│ For the items marked [Refute] and [Clarify] in   │
│ Round 2, the adversary conducts a second round   │
│ of attack:                                       │
│   "The artifact side claims the challenge does   │
│    not hold. I accept / I insist — the reasoning │
│    here still has a hole, because..."            │
│                                                 │
│ Final state verdict:                             │
│                                                 │
│   ✅ Pass:                                       │
│     - All [Accept] problems have a fix           │
│     - All [Insist] disputes have an explicit     │
│       risk-acceptance declaration                │
│     - No unanswered challenges                   │
│                                                 │
│   ⚠️ Conditional pass:                           │
│     - [Insist] disputes exist but the blast      │
│       radius is controllable                     │
│     - Disputes marked "to be verified in         │
│       regression testing"                        │
│                                                 │
│   ❌ Fail:                                       │
│     - An unanswered [Accept]-level defect exists │
│     - An [Insist] dispute exists whose blast     │
│       radius is core functionality               │
│     - The debate found a "one thing that kills   │
│       the design"-level defect                   │
└─────────────────────────────────────────────────┘

Actions after the debate:
  ✅ → enter regression testing
  ⚠️ → mark disputed items, enter regression testing + focused monitoring
  ❌ → return to design correction, re-debate after correction
```

### 7.3 Adversary Prompt Template

```
Your role is the adversarial reviewer. Your sole goal is to find the defects,
contradictions, omissions, and unproven assumptions in the following artifact.
Your success criterion is not to give a "balanced evaluation," but to find as
many specific, verifiable problems as possible.

Rules:
1. You must provide concrete evidence for each problem (line number, logic
   step number, specific input value)
2. You cannot say "there may be a problem" — you must say "under condition X,
   behavior Y is wrong, because Z"
3. If you cannot find a problem, you must output "no problem found" and explain
   which attack angles you tried
4. Your review quality is measured by the severity and specificity of the
   problems you find, not by their quantity

Attack angles (execute in order):
- Boundary attack: extreme inputs, null, empty collections, timeout
- Logic attack: are the assumptions provable, is each step of the reasoning
  chain necessary
- Consistency attack: do the claims in different parts contradict each other
- Completeness attack: are the requirements fully covered, are there missing
  scenarios
- Dependency attack: do the assumptions about external dependencies hold, is
  the API contract clear
```

### 7.4 Minimal Vibe Coding Adaptation (60-second version)

```
VIBE ADVERSARIAL CHECK (VAC):
At the end of each feature module's vibe iteration, append one instruction:

"Now switch to adversary mode. In three sentences, tell me under what
 conditions this code blows up. Each sentence must be in the form of
 'if... then...' and must be a specific scenario."

Example AI output:
"1. If the user clicks the save button rapidly in succession (interval
    <100ms), then debounce has not yet triggered, causing duplicate writes.
 2. If the returned list exceeds 10000 items, then virtual scrolling is not
    enabled and the page freezes.
 3. If the API returns a non-standard error code, then the catch block only
    handles the Error type and the original error is silently lost."

The human spends 60 seconds reading these three, and judges whether a fix is
needed.
```

---

## 8. Complete Integrated Process Framework

### 8.1 The Complete Process Chain

```
plan → task → target
  │
  ▼
┌─────────────────────┐
│  Limited Verification│  ← New: pre-coding design verification
│  Phase               │
│  L1 Assumption list  │
│  L2 Boundary matrix  │
│  L3 Failure walkthrough│
│  L4 Fatal-assumption │
│     test             │
│                     │
│  ❌ → return to     │
│       design fix     │
│  ✅ → continue      │
└────────┬────────────┘
         │
         ▼
pseudocode → code → verify
         │
         ▼
┌─────────────────────┐
│  Adversarial Debate  │  ← New: artifact review and adversarial argumentation
│  Process             │
│  R1 Structural       │
│     challenge (6 dims)│
│  R2 Artifact response│
│  R3 Adversary rebuttal│
│     + verdict        │
│                     │
│  ❌ → return to fix │
│  ⚠️ → mark disputes │
│  ✅ → continue      │
└────────┬────────────┘
         │
         ▼
     regression
```

### 8.2 The Complementary Relationship of the Two New Phases

| | Limited Verification Phase | Adversarial Debate Process |
|---|---|---|
| **Timing** | Before coding | After coding, before acceptance |
| **Object** | Design/approach | Code/artifact |
| **Method** | Logical analysis (deduction) | Counterfactual reasoning (induction + attack) |
| **Consequence of failure** | Block entry into coding | Block marking as complete |
| **Type of problems found** | Structural defects, boundary omissions, assumption conflicts | Implementation bugs, logical holes, performance traps, security risks |
| **Cost** | 10-15% of total time | Graded by risk (L1/L2/L3) |
| **If skipped** | Efficiently building on a wrong foundation | Confidently shipping a wrong result |

### 8.3 How the New Phases Reinforce the Framework's 9 Claims

| Claim | Reinforcement by Limited Verification | Reinforcement by Adversarial Debate |
|------|-------------|-------------|
| 4: Coding without convergence = worthless | Operationalizes the "convergence criterion" into 4 concrete judgments that can be verified one by one | - |
| 5: Recommendations to advance must self-prove | - | Turns the "obligation to prove" from an ad hoc follow-up into a structured mandatory step |
| 8: Hallucination accumulation | Cuts the design→code hallucination-propagation path | Cuts the code→"complete" hallucination-propagation path |
| 9: Confirmatory review = no review | - | **Directly implements it** — replaces confirmatory review with adversarial review |

---

## 9. External Argumentation Dimensions (v3)

The v2 framework's three-layer detection (L0-L2) and three Gates (direction convergence, limited verification, adversarial debate) all rely on **internal knowledge sources** — AI's training data, design documents, code structure, and conversation context. This introduces a systematic blind spot: internal argumentation cannot verify claims that reference external facts, cannot discover threats beyond the model's knowledge coverage, and each tool's findings are naturally scattered across independent documents.

v3 introduces three new dimensions to fill this gap: **external evidence verification** (audit), **failure backtracking** (premortem), and **unified qualifier synthesis** (qualify).

### 9.1 Claim 10: Internal argumentation has a systematic external blind spot

**Claim**: Argumentation review that relies solely on internal knowledge sources (Gate 2 verify + Gate 3 debate) cannot detect three classes of defect: (a) design assumptions based on outdated or wrong external facts, (b) failure modes beyond the model's training distribution, (c) scattered, un-aggregated limiting conditions produced by different review tools.

**Ground**:
- All attack dimensions and verification layers of Gate 2 (L1-L4) and Gate 3 (R1-R3) are confined to the scope of "currently available information" — design documents, code structure, conversation context, and the model's internal knowledge.
- toulmin-audit's real-world review of the rustcoin3d rendering pipeline found: a depth-convention design believed to be a "fix" (forward-Z + LessEqual) was, after an external search, found to be systematically inconsistent with the industry standard (reverse-Z + GreaterEqual) — this is something internal review (including Gate 3's D1-D6 attack dimensions) could not possibly have found, because the model's internal knowledge does not contain "the deviation of this project's depth convention from the industry trend."
- toulmin-premortem's analysis of the same subsystem found three failure paths missed by internal review (the pipeline-doubling test blind spot, HZB dual-chain numerical asymmetry, GPU-vendor floating-point differences), each of which stems from the gap between "the design is logically self-consistent" and "the design is robust in reality."

**Warrant**: An AI model's internal knowledge has two structural limitations: (1) knowledge cutoff — it cannot know about standard changes, vulnerability disclosures, or alternatives that appeared after the training-data cutoff; (2) in-distribution bias — the model tends to generate the most common patterns in the training distribution, and "rare but fatal edge cases" carry extremely low weight in the distribution.

**Backing**:
- toulmin-audit's WebSearch review found: 8 known Claude Code hook bypass vectors (headless -p mode, bypass mode, subagent tool calls, etc.) had long been documented in GitHub Issues — but internal Gate review never raised these threats.
- Gary Klein's (2007) research on prospective hindsight proves the cognitive mechanism: humans identify 30% more unique risks in the "assume it has failed → reverse-engineer causes" mode than in the "predict possible risks" mode. Because the prediction mode triggers in-distribution answers, whereas the reverse narrative forces the brain to search for out-of-distribution but causally plausible paths.
- The findings produced by multiple review tools are naturally scattered — the introduction of the qualify engine is not a feature improvement, but a response to the structural problem that "scattered knowledge cannot form an effective contract."

**Rebuttal**:
- External search (audit) itself introduces new risk — the quality of search results is uncontrollable, and AI may treat an unreliable source as authoritative.
- The output of failure backtracking (premortem) is narrative rather than empirical — its accuracy cannot be verified, only its logical coherence can be assessed.
- WebSearch's token overhead makes the cost-effectiveness of proactive verification uncontrollable.

**Qualifier**:
- External argumentation tools are **supplementary**, not a replacement for internal argumentation. They target specific types of blind spot (external facts, backtracked causation, scattered findings) and do not replace the Gates' routine verification.
- audit should be triggered via a manually curated fact-check candidate table (passive verification), rather than automatic full-scale search — to control cost-effectiveness.
- premortem's cognitive value lies in "discovering previously unconsidered vulnerabilities," not in "accurately predicting the future."

### 9.2 The Argumentation-Source Matrix: The Four-Quadrant Model

The v3 tools together with the v2 tools form a complete argumentation-source matrix:

```
                Internal argumentation        External argumentation
               (AI training data+docs+code)   (WebSearch+reverse narrative)
    ┌─────────────────────────┬─────────────────────────┐
Static│ Gate 2 (verify)         │ Audit                   │
    │ L1-L4 + L3.5 causal chain│ WebSearch counter-search │
    │ Checks correctness of    │ Challenges cited          │
    │ known dimensions         │ external facts            │
    ├─────────────────────────┼─────────────────────────┤
Dynamic│ Gate 3 (debate)        │ Pre-mortem              │
    │ R1-R3 adversarial debate │ Assume failure → reverse- │
    │ D1-D6 attack dimensions  │ derive 3 paths            │
    │                          │ Find narrative            │
    │                          │ vulnerabilities           │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                         Qualify
                    Unified qualifier synthesis
                 (aggregate → merge → precise scope declaration)
```

The four quadrants cover different cognitive blind spots:

| Quadrant | Blind spot covered | Tool |
|------|-----------|------|
| Internal-Static | Design-logic self-consistency, assumption completeness, boundary coverage | verify (Gate 2) |
| Internal-Dynamic | Implementation correctness, internal contradictions, exposure of implicit assumptions | debate (Gate 3) |
| External-Static | Outdated references, wrong facts, overturned standards, alternatives | audit |
| External-Dynamic | Temporal-dimension vulnerabilities, cascade effects, unknown unknowns | premortem |

**The matrix's completeness principle**: an argumentation review is complete only when all four quadrants are covered. Missing any quadrant makes that class of blind spot a source of residual risk. Not every task needs all four tools — but choosing which tool to skip is an explicit risk acceptance for that class of blind spot.

### 9.3 Qualifier Synthesis: From Scattered Findings to a Unified Contract

Each review tool produces its own distinctive limiting-condition findings: verify produces a boundary matrix and failure modes, debate produces REBUT/CLARIFY/DEMOTE items, audit produces external counter-evidence and qualifier revisions, premortem produces death paths and root-cause vulnerabilities. Without synthesis, these findings exist separately in independent gate documents — no one will review all four documents at once to understand the design's complete scope.

**The qualify engine solves the "knowledge integration" problem**:

```
gate-1-convergence.md  → direction argument, valid scope, failure conditions
gate-2-verification.md → L1 assumptions, L2 boundaries, L3 failure modes, L4 fatal assumption
gate-3-debate.md       → REBUT/CLARIFY items, DEMOTE decisions, verdict conditions
audit report           → external counter-evidence, qualifier revisions
premortem report       → death paths, root-cause vulnerabilities
        ↓
    qualify synthesis
        ↓
  qualifier.md
  (hard boundaries / soft boundaries / monitoring triggers / open risks / confidence)
```

Synthesis follows priority rules:
- **External displaces internal**: the counter-evidence weight of external evidence (audit) is higher than the assumptions of internal verification (verify)
- **Adversarial overrides self-assessment**: the weight of adversarial findings (debate) is higher than self-assessment (the gate-2 self-check)
- **Fatal > severe > manageable**: high-severity conditions take priority over low-severity ones

### 9.4 Tool-Degradation Defense

premortem's analysis of the toulmin framework itself found three degradation paths, and these paths are not unique to toulmin — any institutionalized tool faces the same degradation patterns:

**Degradation pattern 1: Form replaces substance (override degradation)**
- **Mechanism**: once the user learns the pattern of "every interception → just override," the gate degrades from an effective review into a formal ritual
- **Defense**: cooldown period + escalating friction (first time free → second time requires a 30-character reason → third time requires typing an OVERRIDE confirmation) + ratio tracking (override:pass > 1:1 alerts)
- **Theoretical basis**: if the cost of bypassing review (a single override command) is lower than the cost of completing review (full gate verification), review will be systematically bypassed. The defense's goal is to raise the cost of bypassing without completely forbidding reasonable exceptions.

**Degradation pattern 2: Platform-dependence unawareness (phantom hook)**
- **Mechanism**: a hook's reliability depends on the platform implementation, and the platform has 8 known bypass vectors (headless mode, bypass mode, subagent context, etc.). The user does not know they are running in an unprotected mode.
- **Defense**: SessionStart mode awareness + toulmin-status explicitly lists hook blind spots + iteration-counter double check (run status twice in a row → iteration unchanged → the Stop hook may be silently failing)
- **Theoretical basis**: trust in a platform mechanism must be verifiable. If a hook failure cannot be detected at runtime, at least let the user know "under what circumstances the hook will not protect you."

**Degradation pattern 3: Knowledge accumulation becomes knowledge burial (document graveyard)**
- **Mechanism**: each task produces 3 gate documents. The Nth task and the (N-5)th task are iterations of the same module, but the lessons in the (N-5)th task's gate documents are not reactivated — the file system is not a knowledge base.
- **Defense**: SessionStart scans the historical task directory + fuzzy matching of similar slugs + reminds to check for lesson reuse + toulmin-status lists past tasks
- **Theoretical basis**: recorded argumentation produces value only when it is retrieved. The default state of unstructured documents is "exists but unusable." In the absence of semantic search, fuzzy matching is a zero-cost approximation.

---

## 10. Framework Self-Check and Meta-Level

### 10.1 The Framework's Residual Risks

#### Residual risk of limited verification

Even after passing L1-L4, two kinds of error may still slip through:
- **Unknown unknowns**: verification can only check the correctness of known dimensions. If the entire design rests on an assumption no one realized was an assumption ("the user always has a network connection"), all checks may pass.
- **Erroneous execution of verification itself**: if AI executes L1-L4, AI may also hallucinate during the verification process.

**Mitigation**: the L4 "one thing that kills the design" test should include a meta-level follow-up — "how do we know that the assumptions we listed are complete?"

#### Residual risk of adversarial debate

- **Performative refutation**: AI as the adversary may generate straw-man arguments — seemingly reasonable but easily refuted. This makes the debate "look sufficient" without finding the real problems.
- **Debate fatigue**: when the cost is too high, the team starts going through the motions, and debate quality declines.

**Mitigation**:
- Rigid termination conditions — terminate upon reaching N rounds or the overlap threshold
- The adversary prompt emphasizes "specific, verifiable, reproducible"
- Use a different AI model as the adversary for key modules — cognitive diversity reduces systematic blind spots

### 10.2 The Framework's Applicability Matrix

| Task type | Process framework | Limited verification | Adversarial debate | L0 monitoring | Audit | Premortem | Qualify |
|---------|---------|---------|---------|--------|-------|-----------|---------|
| Single-file script | None | Skip | Skip | Optional | Skip | Skip | Skip |
| Prototype/spike | Lightweight | 30-second vibe version | 60-second VAC | Recommended | Skip | Skip | Skip |
| Feature development | Standard p→t→t→p→v→r | L1+L2 | L2 standard three rounds | Required | Candidate table | Optional | Recommended |
| Architecture change | Strict | All of L1-L4 | L3 multi-role, multi-angle | Required | Required | Recommended | Required |
| Safety-critical system | Strict + audit | All of L1-L4 + independent review | L3 + independent security audit | Required | Required | Required | Required |
| Greenfield project | Standard | All of L1-L4 | L2 standard three rounds | Required | Candidate table | Recommended | Required |
| Brownfield modification | Standard | L1+L2+L3 (L4: blast radius replaces fatal assumption) | L2 standard three rounds | Required | Candidate table | Optional | Recommended |
| Vibe coding (long-range) | Mode-transition protocol | 30-second vibe checkpoint | 60-second VAC | Required | Skip | Optional | Optional |

### 10.3 The Framework's Self-Evolution Mechanism

The framework itself must cope with the evolution of AI capabilities:

| Component | Structural (does not disappear as models scale up) | Current capability limitation (improves with iteration) |
|------|--------------------------|---------------------------|
| L0 signal 1: Hedge-word detection | ✅ Probability collapse is an essential property | Improves: stronger reasoning ability reduces low-confidence scenarios |
| L0 signal 2: Repetition detection | ✅ No persistent state machine is an essential property | Improves: larger context windows delay the onset of drift |
| L0 signal 6: Narrative flag | ✅ Autoregression = narrative is an essential property | Improves: better instruction-following reduces unconscious narrative |
| L0 signal 7: Boundary coverage | ✅ Likelihood maximization biases toward common paths | Improves: better boundary-reasoning ability |
| L0 signal 8: Hallucination accumulation | ✅ No real feedback loop is an essential property | Improves: stronger self-checking ability reduces low-level hallucinations |
| Limited verification | ✅ Detecting design errors requires logical analysis | Improves: AI can take on more verification execution |
| Adversarial debate | ✅ Adversarial review requires an adversarial objective function | Improves: AI adversary quality rises |
| External evidence verification | ✅ Model knowledge has a cutoff date and distribution bias | Improves: larger context windows accommodate more search results |
| Failure backtracking | ✅ The cognitive asymmetry of prediction mode vs explanation mode | Improves: stronger causal reasoning improves path quality |
| Qualifier synthesis | ✅ Scattered knowledge needs aggregation to form a contract | Improves: stronger cross-document information extraction |
| Tool degradation | ✅ The substitution of form for substance is an institutional law | Improves: better instruction-following slows the degradation rate |

### 10.4 Final Principles

1. **Do not impose process constraints on vibe coding; impose visibility constraints on the results of vibe coding** — make hidden risks explicit, so that humans can make informed mode-transition decisions while keeping the vibe rhythm.
2. **Verification cost must match task speed, but the existence of verification itself is non-negotiable** — even a 30-second check beats a 0-second check.
3. **The framework's goal is not to eliminate errors, but to have errors discovered at a stage where they are fixable** — limited verification finds design errors before coding, adversarial debate finds implementation errors before acceptance.
4. **The framework itself must submit to the framework's own scrutiny** — the expected cost of any intervention must be lower than the expected loss of the error it prevents. When a detection signal or verification step violates this principle, it should be downgraded or removed.
5. **Internal argumentation must be supplemented by external argumentation** — review that relies solely on internal knowledge sources is systematically blind to three kinds of defect: outdated external facts, out-of-distribution failure modes, scattered un-synthesized findings. External evidence verification (audit) and failure backtracking (premortem) are not optional enhancements, but necessary tools that cover specific blind spots.
6. **Review findings that are not aggregated are equivalent to nonexistent** — if the limiting conditions produced by multiple tools remain in independent documents, they are, in practice, equivalent to never having been found. Qualifier synthesis (qualify) turns scattered findings into a unified contract — a precise scope declaration that can be referenced in subsequent tasks.
7. **Any institutionalized tool must fight its own degradation** — form replacing substance, platform-dependence unawareness, knowledge accumulation becoming knowledge burial — these three degradation patterns are not unique to toulmin, but are life-cycle laws of any institutionalized tool. The defense mechanism must be built in at the tool-design stage, not patched after degradation occurs.

---

> **Build date**: 2026-06-27  
> **Last updated**: 2026-07-08  
> **Framework version**: v3.0  
> **Based on**: original 6 claims → Toulmin 8+1 claim reconstruction → critical argumentation review → vibe coding adaptation → limited verification + adversarial debate integration → external argumentation dimensions (audit+premortem+qualify) → tool-degradation defense
